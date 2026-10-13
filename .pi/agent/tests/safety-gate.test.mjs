import assert from "node:assert/strict";
import test from "node:test";
import safetyGate from "../extensions/safety-gate.ts";

const check = async (input, { hasUI = true, approved = false, toolName = "bash" } = {}) => {
  let handler;
  const prompts = [];
  safetyGate({
    on(event, callback) {
      assert.equal(event, "tool_call");
      handler = callback;
    },
  });
  const result = await handler(
    { toolName, input },
    {
      hasUI,
      ui: {
        async confirm(title, message) {
          prompts.push({ title, message });
          return approved;
        },
      },
    },
  );
  return { result, prompts };
};

// These are strings passed to the handler, never executed as shell commands.
const safeCommands = [
  "pwd; ls -a; git status --short",
  "rg -n 'hunk' .config nix",
  "python3 --version",
  "node --version 2>&1",
  "python3 -c 'from pathlib import Path; print(Path(\"file\").read_text())'",
  "python3 -c 'from pathlib import Path; s=Path(\"file\").read_text(); print(s.replace(chr(39), chr(34)))' | bash -n",
  "node -e 'console.log(1 + 2)'",
  "python3 -c 'import sys; sys.stdout.write(\"hello\")'",
  "git diff >/dev/null 2>&1",
  "git diff > /dev/null",
  'git diff > "/dev/null"',
  "git diff 2>&1 | head",
  "rg 'a > b' file",
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], input=text, text=True)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], text=True, input=text)'`,
  `git diff --check; git diff -- nix/home/starship.nix; alejandra --check nix/home/starship.nix; python3 -c 'from pathlib import Path;
import subprocess; text = Path("nix/home/starship.nix").read_text().split("        text = " + chr(39)*2 + "\\n", 1)[1].split("\\n        " + chr(39)*2 + ";", 1)[0]; result = subprocess.run(["bash", "-n"], input=text.replace(chr(39)*2 + "\${", "\${"), text=True); raise SystemExit(result.returncode)'`,
];

for (const command of safeCommands) {
  test(`allows without confirmation: ${command}`, async () => {
    const { result, prompts } = await check({ command }, { hasUI: false });
    assert.equal(result, undefined);
    assert.equal(prompts.length, 0);
  });
}

const riskyCommands = [
  "rm -rf directory",
  "mv temporary file",
  "cp source destination",
  "sudo command",
  "git reset --hard",
  "sed -i 's/old/new/' file",
  "echo text >file",
  "echo text >>file",
  "echo text > 'file'",
  'echo text > "file"',
  "echo text >|file",
  "exec 3<>file",
  "bash -c 'echo text >file'",
  'bash -lc "echo text >file"',
  "eval 'echo text >file'",
  "python3 script.py",
  "python3 -m unknown_module",
  "node script.js",
  'python3 -c "$script"',
  'node -e "$(generate_code)"',
  'python3 -c \'from pathlib import Path; Path("file").write_text("text")\'',
  'python3 -c \'open("file", "w").write("text")\'',
  'python3 -c \'open("file", "r+")\'',
  "python3 -c 'import os; os.open(\"file\", os.O_WRONLY)'",
  'python3 -c \'import os; os.replace("temporary", "file")\'',
  'node -e \'fs.writeFileSync("file", "text")\'',
  'node -e \'fs.openSync("file", "w")\'',
  "python3 -c 'import subprocess; subprocess.run(command)'",
  `python3 -c 'import subprocess; subprocess.run(["bash"], input=text, text=True)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n", "file"], input=text, text=True)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], input=text, text=True, shell=True)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], input=text, text=True, executable=other)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], input=text, text=True, **options)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], input=Path("file").write_text("text"), text=True)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], input=text, text=True); subprocess.run(command)'`,
  `python3 -c 'import subprocess; subprocess.run(["bash", "-n"], input=text, text=True); subprocess.Popen(command)'`,
  `python3 -c 'import subprocess as runner; runner.run(["bash", "-n"], input=text, text=True)'`,
  `python3 -c 'from subprocess import run; run(["bash", "-n"], input=text, text=True)'`,
  "python3 -c 'eval(code)'",
  "pnpm install",
  "mktemp",
];

for (const command of riskyCommands) {
  test(`requires confirmation: ${command}`, async () => {
    const denied = await check({ command });
    assert.equal(denied.result?.block, true);
    assert.equal(denied.prompts.length, 1);
    assert.ok(denied.prompts[0].message.includes(command));

    const approved = await check({ command }, { approved: true });
    assert.equal(approved.result, undefined);
    assert.equal(approved.prompts.length, 1);

    const unattended = await check({ command }, { hasUI: false });
    assert.equal(unattended.result?.block, true);
    assert.equal(unattended.prompts.length, 0);
  });
}

test("still confirms namespaced and nested mutations", async () => {
  for (const [toolName, input] of [
    ["functions.edit", { path: "file", edits: [] }],
    ["write", { path: "file", content: "text" }],
    ["ast_grep_replace", { apply: true }],
    ["lsp_navigation", { apply: true }],
    [
      "multi_tool_use.parallel",
      {
        tool_uses: [
          { recipient_name: "functions.bash", parameters: { command: "echo text >file" } },
        ],
      },
    ],
    [
      "multi_tool_use.parallel",
      {
        tool_uses: [
          { recipient_name: "functions.write", parameters: { path: "file", content: "text" } },
        ],
      },
    ],
  ]) {
    const { result, prompts } = await check(input, { toolName });
    assert.equal(result?.block, true);
    assert.equal(prompts.length, 1);
  }
});
