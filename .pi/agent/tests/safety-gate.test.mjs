import assert from "node:assert/strict";
import test from "node:test";
import { mkdtempSync, mkdirSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import safetyGate from "../extensions/safety-gate.ts";

const check = async (input, { hasUI = true, approved = false, toolName = "bash", cwd = process.cwd() } = {}) => {
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
      cwd,
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
  "rm -rf directory",
  "mv temporary file",
  "cp source destination",
  "mkdir -p src/new; touch src/new/file",
  "unlink src/old; rmdir src/empty",
  "echo text >file",
  "echo text >>file",
  "echo text > 'file'",
  'echo text > "file"',
  "echo text >|file",
  "exec 3<>file",
  "printf text | tee file",
  "git -C repo status --short",
  "git -Crepo --no-pager diff",
  "/usr/bin/git log --oneline",
  "env GIT_PAGER=cat git diff",
  "git fetch origin",
  "git branch --list; git branch -a; git tag --list",
  "git stash list; git stash show; git reflog show; git worktree list",
  "git config --get user.name; git remote -v",
  "jj status; jj diff; jj log; jj show",
  "jj -R repo --no-pager st",
  "jj --at-op=@ log",
  "jj bookmark list; jj b l; jj tag list",
  "jj op log; jj operation show; jj file list; jj file search pattern",
  "jj workspace list; jj git fetch; jj git remote list; jj git root",
  "jj config list; jj config get user.name",
  "pwd; ls -a; git status --short",
  "rg -n 'hunk' .config nix",
  "rg git file; rg rm file; echo git push; printf '%s' jj",
  'echo "literal\\q" > file',
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
  "sudo command",
  "chmod +x file",
  "launchctl bootout service",
  "defaults write domain key value",
  "dd if=input of=output",
  "vp build",
  "sed -i 's/old/new/' file",
  "rm -rf .",
  "rm -rf /",
  "rm ../outside",
  "mv src/file /tmp/file",
  "cp /tmp/file src/file",
  "rm -rf src/*",
  "rm -rf .git",
  "rm -rf .jj",
  "echo text > .env.local",
  "echo text > ../outside",
  "echo text > /etc/hosts",
  'echo text > "$target"',
  "cd /tmp && rm file",
  "env rm file",
  "find src -type f -delete",
  "cp file -t/tmp",
  "cp -RL src destination",
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

test("still confirms protected or unclear mutation tools", async () => {
  for (const [toolName, input] of [
    ["functions.edit", { path: ".env", edits: [] }],
    ["write", { path: ".git/config", content: "text" }],
    ["write", { path: "AGENTS.md", content: "text" }],
    ["edit", { path: ".pi/agent/extensions/safety-gate.ts", edits: [] }],
    ["write", { path: "../outside", content: "text" }],
    ["write", { content: "text" }],
    ["lsp_navigation", { apply: true, path: "file", operation: "rename" }],
    ["lsp_navigation", { apply: true, path: "file", newFilePath: "../outside", operation: "rename_file" }],
    ["ast_grep_replace", { apply: true, paths: ["src/**"] }],
    ["ast_grep_replace", { apply: true }],
    ["lsp_navigation", { apply: true }],
    [
      "multi_tool_use.parallel",
      {
        tool_uses: [
          { recipient_name: "functions.bash", parameters: { command: "echo text >.env" } },
        ],
      },
    ],
    [
      "multi_tool_use.parallel",
      {
        tool_uses: [
          { recipient_name: "functions.write", parameters: { path: ".env", content: "text" } },
        ],
      },
    ],
  ]) {
    const { result, prompts } = await check(input, { toolName });
    assert.equal(result?.block, true);
    assert.equal(prompts.length, 1);
    const approved = await check(input, { toolName, approved: true });
    assert.equal(approved.result, undefined);
    const unattended = await check(input, { toolName, hasUI: false });
    assert.equal(unattended.result?.block, true);
    assert.equal(unattended.prompts.length, 0);
  }
});

const blockedCommands = [
  "git commit -m message", "git commit --amend", "git push", "git push --force",
  "git reset", "git reset --soft HEAD~1", "git reset --hard",
  "git restore file", "git checkout -- file", "git checkout branch", "git switch -C branch",
  "git clean -fd", "git merge branch", "git rebase main", "git revert HEAD",
  "git cherry-pick abc", "git pull", "git apply patch", "git am patch",
  "git stash", "git stash pop", "git stash drop", "git stash clear",
  "git branch -D branch", "git branch --list --delete branch", "git tag -d tag",
  "git worktree remove path", "git reflog expire --all", "git remote remove origin",
  "git config user.name other", "git config --list --unset user.name",
  "git add file", "git rm file", "git mv old new", "git gc", "git update-ref refs/heads/main abc",
  "git unknown-alias", "git fetch --prune", "git fetch origin +main:main",
  "git diff --output=/tmp/diff", "git diff --ext-diff",
  "git -C repo commit -m message", "git -Crepo reset --hard",
  "/usr/bin/git --git-dir=repo/.git push",
  "git -c alias.safe=push safe", "git --config-env=alias.safe=VALUE safe",
  "env git push", "command git reset --hard", "git status;git push",
  "git status&&git push", "git status | git reset --hard",
  "bash -c 'git push'", 'sh -lc "git reset --hard"',
  "jj commit", "jj ci", "jj describe", "jj desc", "jj new",
  "jj abandon", "jj rebase", "jj squash", "jj split", "jj absorb",
  "jj restore file", "jj revert", "jj edit revision", "jj undo", "jj redo",
  "jj bookmark delete branch", "jj b d branch", "jj bookmark set branch",
  "jj tag delete tag", "jj op restore abc", "jj op abandon abc",
  "jj workspace forget name", "jj file delete file", "jj file untrack file",
  "jj git push", "jj git export", "jj git import", "jj git remote remove origin",
  "jj config set user.name other", "jj run -- command",
  "jj -R repo git push", "jj --repository=repo abandon",
  "/usr/local/bin/jj --ignore-working-copy undo",
  "jj --config 'aliases.safe=[\"git\",\"push\"]' safe",
  "jj log --config 'ui.pager=\"command\"'",
  "jj --ignore-immutable rebase", "jj unknown-alias",
  "bash -lc 'jj git push'",
  "eval 'git push'", "eval 'jj abandon'",
  'git push "$remote"', 'jj git push "$remote"',
  'git status; git push "$remote"',
  "git fetch --upload-pack=command", "git fetch -u origin",
  "git branch --list --set-upstream-to=origin/main main",
  "git cat-file --filters HEAD:file",
];

for (const command of blockedCommands) {
  test("hard blocks even with approval: " + command, async () => {
    for (const hasUI of [true, false]) {
      const { result, prompts } = await check({ command }, { approved: true, hasUI });
      assert.equal(result?.block, true);
      assert.equal(prompts.length, 0);
    }
  });
}

test("allows routine direct, namespaced, and nested tool calls without a UI", async () => {
  for (const [toolName, input] of [
    ["edit", { path: "src/file.ts", edits: [] }],
    ["functions.write", { path: "src/new.ts", content: "text" }],
    ["ast_grep_replace", { apply: false }],
    ["lsp_navigation", { apply: false }],
    ["multi_tool_use.parallel", { tool_uses: [
      { recipient_name: "functions.write", parameters: { path: "src/new.ts", content: "text" } },
      { recipient_name: "functions.bash", parameters: { command: "mv src/old src/new" } },
    ] }],
  ]) {
    const { result, prompts } = await check(input, { toolName, hasUI: false });
    assert.equal(result, undefined);
    assert.equal(prompts.length, 0);
  }
});

test("checks all nested calls before asking for approval", async () => {
  const { result, prompts } = await check({
    tool_uses: [
      { recipient_name: "write", parameters: { path: ".env", content: "text" } },
      { recipient_name: "multi_tool_use.parallel", parameters: { tool_uses: [
        { recipient_name: "bash", parameters: { command: "jj git push" } },
      ] } },
    ],
  }, { toolName: "multi_tool_use.parallel", approved: true });
  assert.equal(result?.block, true);
  assert.equal(prompts.length, 0);
});

test("resolves symlinks, missing descendants, and directory scopes", async () => {
  const base = mkdtempSync(join(tmpdir(), "pi-safety-gate-"));
  const cwd = join(base, "workspace");
  const outside = join(base, "outside");
  mkdirSync(cwd);
  mkdirSync(outside);
  mkdirSync(join(cwd, "src"));
  writeFileSync(join(cwd, "src", "file.ts"), "original");
  mkdirSync(join(cwd, "protected"));
  writeFileSync(join(cwd, "protected", ".env"), "test fixture, not a secret");
  symlinkSync(outside, join(cwd, "escape"));
  symlinkSync(join(cwd, "src"), join(cwd, "local"));
  symlinkSync(join(outside, "missing"), join(cwd, "dangling"));
  mkdirSync(join(cwd, "links"));
  symlinkSync(outside, join(cwd, "links", "outside"));
  try {
    for (const path of ["escape/new/file.ts", "escape/../file.ts", "dangling", "dangling/new/file.ts", ".", "../outside/file", ".git/config", ".jj/repo/store"]) {
      const { result } = await check({ path, content: "text" }, { toolName: "write", cwd, hasUI: false });
      assert.equal(result?.block, true, path);
    }
    for (const path of ["src/new/file.ts", "local/new/file.ts"]) {
      const { result } = await check({ path, content: "text" }, { toolName: "write", cwd, hasUI: false });
      assert.equal(result, undefined, path);
    }
    for (const command of ["rm -rf protected", "mv protected src", "cp -R protected src", "rm escape/file", "cp -R src links"]) {
      const { result } = await check({ command }, { cwd, hasUI: false });
      assert.equal(result?.block, true, command);
    }
    const ordinary = await check({ command: "rm -rf src" }, { cwd, hasUI: false });
    assert.equal(ordinary.result, undefined);
    const applied = await check({ apply: true, paths: ["src/file.ts"] }, { cwd, hasUI: false, toolName: "ast_grep_replace" });
    assert.equal(applied.result, undefined);
    const broad = await check({ apply: true, paths: ["src"] }, { cwd, hasUI: false, toolName: "ast_grep_replace" });
    assert.equal(broad.result?.block, true);
  } finally {
    rmSync(base, { recursive: true, force: true });
  }
});

test("preserves permissions through namespaced and deeply nested calls", async () => {
  const scenarios = [
    ["bash", { command: "git diff --staged" }],
    ["hypa_shell", { cmd: "jj diff -r @" }],
    ["bash", { script: "jj git push" }],
    ["edit", { path: "src/file.ts", edits: [] }],
    ["write", { path: ".env", content: "text" }],
    ["lsp_navigation", { path: "src/file.ts", apply: true, operation: "rename" }],
  ];
  for (const [toolName, input] of scenarios) {
    for (const hasUI of [true, false]) {
      for (const approved of [true, false]) {
        const options = { hasUI, approved };
        const direct = await check(input, { ...options, toolName });
        let nested = { name: "vendor.functions." + toolName, arguments: input };
        for (let depth = 0; depth < 4; depth++) {
          nested = { name: "unknown.wrapper", arguments: { tool_uses: [nested] } };
        }
        const wrapped = await check({ tool_uses: [nested] }, { ...options, toolName: "multi_tool_use.parallel" });
        assert.deepEqual(wrapped.result, direct.result);
        assert.equal(wrapped.prompts.length, direct.prompts.length);
        if (wrapped.prompts.length && toolName !== "bash" && toolName !== "hypa_shell") {
          assert.ok(wrapped.prompts[0].message.includes("vendor.functions." + toolName));
        }
      }
    }
  }
});

test("hard blocks take priority over approval in either batch order", async () => {
  const blocked = { recipient_name: "functions.bash", parameters: { command: "git push" } };
  const expected = await check(blocked.parameters, { approved: true });
  for (const needsApproval of [
    { recipient_name: "functions.write", parameters: { path: ".env", content: "text" } },
    { recipient_name: "functions.bash", parameters: { command: "sudo command" } },
  ]) {
    for (const tool_uses of [[needsApproval, blocked], [blocked, needsApproval]]) {
      for (const hasUI of [true, false]) {
        const { result, prompts } = await check({ tool_uses }, {
          toolName: "multi_tool_use.parallel", hasUI, approved: true,
        });
        assert.equal(result?.block, true);
        assert.equal(prompts.length, 0);
        assert.deepEqual(result, expected.result);
      }
    }
  }
});

test("simple jj subcommand tables allow only their existing inspection modes", async () => {
  for (const [command, inspections, mutation] of [
    ["bookmark", ["list", "l"], "delete"], ["b", ["list", "l"], "d"],
    ["tag", ["list", "l"], "delete"],
    ["operation", ["log", "show", "diff"], "restore"],
    ["op", ["log", "show", "diff"], "abandon"],
    ["file", ["list", "show", "annotate", "search"], "delete"],
    ["workspace", ["list", "root"], "forget"],
    ["config", ["list", "get", "path"], "set"],
  ]) {
    for (const subcommand of inspections) {
      const { result, prompts } = await check({ command: "jj " + command + " " + subcommand }, { hasUI: false });
      assert.equal(result, undefined);
      assert.equal(prompts.length, 0);
    }
    for (const subcommand of ["", mutation, "unknown"]) {
      const { result, prompts } = await check({ command: "jj " + command + " " + subcommand }, { approved: true });
      assert.equal(result?.block, true);
      assert.equal(prompts.length, 0);
    }
  }
});

test("ignores malformed nested entries without losing valid sibling calls", async () => {
  const { result, prompts } = await check({ tool_uses: [
    null, false, "bash", [], {}, { name: "", arguments: {} },
    { name: "unknown.tool", arguments: null },
    { name: "functions.bash", arguments: { command: "jj diff" } },
  ] }, { toolName: "multi_tool_use.parallel", hasUI: false });
  assert.equal(result, undefined);
  assert.equal(prompts.length, 0);
});
