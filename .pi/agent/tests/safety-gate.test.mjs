import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";
import safetyGate from "../extensions/safety-gate.ts";

// Commands under test are never executed. Only fixture Git init is executed.
const base = mkdtempSync(join(tmpdir(), "pi-safety-gate-"));
const repo = join(base, "repo");
const other = join(base, "other");
const outside = join(base, "outside");
const standalone = join(base, "jj-only");
for (const directory of [repo, other, outside, standalone]) mkdirSync(directory);
for (const directory of [repo, other]) execFileSync("git", ["init", "-q", directory]);
mkdirSync(join(standalone, ".jj"));
mkdirSync(join(repo, "src"));
mkdirSync(join(repo, "ignored"));
writeFileSync(join(repo, ".gitignore"), "ignored/\n");
writeFileSync(join(repo, "src", "file.ts"), "original");
symlinkSync(outside, join(repo, "escape"));
symlinkSync(join(repo, "src"), join(outside, "into-repo"));
symlinkSync(join(outside, "missing"), join(repo, "dangling"));
symlinkSync("../outside/missing-relative", join(repo, "relative-dangling"));
after(() => rmSync(base, { recursive: true, force: true }));

async function check(input, { toolName = "bash", cwd = repo, approved = false, hasUI = false } = {}) {
  let handler;
  safetyGate({ on(name, callback) { assert.equal(name, "tool_call"); handler = callback; } });
  const prompts = [];
  const result = await handler({ toolName, input }, {
    cwd, hasUI,
    ui: { async confirm(title, message) { prompts.push({ title, message }); return approved; } },
  });
  return { result, prompts };
}

async function allowed(command, options) {
  const { result, prompts } = await check({ command }, options);
  assert.equal(result, undefined, command);
  assert.equal(prompts.length, 0, command);
}

async function denied(command, pattern) {
  const { result, prompts } = await check({ command }, { hasUI: true, approved: true });
  assert.equal(result?.block, true, command);
  if (pattern) assert.match(result.reason, pattern, command);
  assert.equal(prompts.length, 0, command);
}

test("commit-producing workflows and remote writes cannot be approved", async () => {
  for (const command of [
    "git commit -m done", "git commit --amend --no-edit", "git commit-tree tree",
    "git commit -m '--help'", "jj new -m '-h'", "git merge -m --abort feature",
    "git merge -m --no-commit feature",
    "git merge feature", "git rebase main", "git cherry-pick abc", "git revert abc",
    "git am changes.patch", "git stash", "git stash push", "git stash create",
    "git fast-import", "git notes add", "git filter-branch", "git replay main",
    "git merge --no-commit --commit feature", "git cherry-pick --no-commit --continue",
    "git push", "git push --dry-run", "git push --delete origin main",
    "git send-pack origin main", "git http-push origin", "git receive-pack repo",
    "git subtree push --prefix=src origin main", "git lfs push origin", "git svn dcommit",
    "git push \"$REMOTE\"", "git push && echo \"$HOME\"", "git push refs/*",
    "sudo git push", "timeout 5 git push", "xargs git push",
    "jj commit", "jj ci -m done", "jj new", "jj new --no-edit", "jj describe -m done",
    "jj desc -m done", "jj split", "jj squash", "jj rebase -d main", "jj duplicate @",
    "jj git push", "jj git push --dry-run", "jj gerrit push",
    "git status; git push", "git status && git commit -m done",
    "command git push", "env git push", "/usr/bin/git push",
    "git -C . --no-pager push", "git --git-dir=.git push", "git -c foo=bar push",
    "jj -R . git push", "jj --repository=. --quiet ci", "jj --config foo=bar git push",
    "bash -c 'git push'", "sh -c 'jj ci'", 'git "pu"sh', "git pu\\\nsh",
  ]) await denied(command);
});


test("all unprotected commands follow Pi defaults without approval", async () => {
  for (const cwd of [repo, outside]) {
    for (const command of [
      "node rewrite.mjs", "node --test tests.mjs", "rex whoami --json",
      "rex run 'git push'", "python -c 'print(1)'", "./rewrite.sh",
      "touch file", "mkdir -p dir", "mv old new", "chmod +x script",
      "echo text > file", "echo $HOME", "echo $(pwd)", "echo 'git push'",
      "find . -delete", "rg --pre script pattern", "powershell script",
      "git status", "git reset --hard", "git add file",
      "git config --global user.name Test", "git diff --output=/tmp/patch",
      "jj git import",
      "jj git export", "jj undo", "jj restore file", "git merge --abort",
      "git merge --no-commit feature", "git stash apply", "command -v git",
    ]) await allowed(command, { cwd, hasUI: true });
  }
});

test("all recognized remote Git/jj operations are user-run", async () => {
  for (const command of [
    "git fetch", "git pull --ff-only", "git clone url", "git ls-remote",
    "git remote update", "git remote show origin", "git remote prune origin",
    "git submodule update --init", "git submodule add url",
    "git lfs pull", "git lfs fetch", "git svn fetch", "git p4 sync",
    "git subtree pull", "jj git fetch", "jj git clone url", "jj gerrit push",
    "git archive --remote=host HEAD",
    "bash -lc 'git fetch'",
  ]) await denied(command, /Remote|remote/);
});

test("all direct gh commands are blocked, including wrappers and nested shell calls", async () => {
  for (const command of [
    "gh --help", "gh auth status", "gh api repos/owner/repo", "gh pr view",
    "/run/current-system/sw/bin/gh repo sync", "command gh --version",
    "env gh auth git-credential", "timeout 5 gh api user",
    "bash -lc 'gh pr list'",
    "echo ok && gh --help",
  ]) await denied(command, /gh/);
  await allowed("echo gh api user");
  await allowed("node script.mjs gh api user");
  await allowed("rex run 'gh api user'");
});

test("aliases, unknown commands and configuration overrides are not inspected", async () => {
  for (const command of [
    "git p", "git c", "git cm done", "git unknown-external-command", "jj publish",
    "git -c alias.p=push p", "git -calias.p=push p",
    "git --config-env=alias.p=VALUE p", "git --exec-path=/tmp status",
    "jj --config 'aliases.p=[\"git\",\"push\"]' p",
    "jj --config-file /tmp/config status", "GIT_CONFIG_COUNT=1 git status",
    "env GIT_SSH_COMMAND=custom git status", "JJ_CONFIG=/tmp/config jj status",
    "git diff --ext-diff", "git --unknown-option status",
    "git-upload-pack repo", "git-remote-https origin url",
    "ssh host 'git push'", "ssh host 'gh api user'",
  ]) await allowed(command, { hasUI: true });
});

test("rm and cp are denied outside repositories without prompting", async () => {
  for (const command of [
    `rm -rf '${outside}/file'`, `cp src/file.ts '${outside}/file'`,
    `cp -t '${outside}' src/file.ts`,
    `cp --target-directory='${outside}' src/file.ts`,
    `cp -t'${outside}' src/file.ts`,
    `cd '${outside}' && rm file`,
    `cd '${outside}' && cp source target`,
  ]) await denied(command, /Outside a Git\/jj repository/);
  await denied("rm $TARGET", /scope/);
  await denied("cp file $TARGET", /scope/);
  await denied("rm *.ts", /scope/);
  await denied("cp -S suffix source target", /option/);
  await denied(`cd '${outside}' || cd '${repo}'; rm file`, /scope/);
});

test("rm and cp can write in any repository; cp checks destinations, not sources", async () => {
  for (const cwd of [repo, standalone]) {
    await allowed("rm -rf ignored/file new/file", { cwd });
    await allowed("cp source target", { cwd });
    await allowed("rm -- -filename", { cwd });
    await allowed("cp -- -source -target", { cwd });
  }
  await allowed(`cp '${outside}/file' '${repo}/new/file'`, { cwd: outside });
  await allowed(`cp -t '${repo}/src' '${outside}/file'`);
  await allowed(`cp --target-directory='${repo}/src' '${outside}/file'`);
  await allowed(`cd '${other}' && rm file`);
  await allowed(`cd '${other}' && cp source target`);
});

test("protected paths resolve symlinks and recursive copy destinations", async () => {
  for (const command of [
    "rm escape/file", "rm dangling", "rm relative-dangling/new/file",
    "rm escape/../file", "cp src/file.ts escape/file",
    "cp src/file.ts dangling", "cp -R src .",
  ]) await denied(command);
  await allowed(`rm '${outside}/into-repo/file'`);
  const directory = join(repo, "with-links");
  mkdirSync(directory);
  symlinkSync(outside, join(directory, "outside"));
  await denied("cp -R src with-links");
  await allowed("rm -rf with-links");
});

test("shell wrappers and command chains retain protected-command checks", async () => {
  for (const command of [
    "rex whoami --json && git push", "node test.mjs; jj ci",
    "env FOO=bar git push", "command git push", "timeout 5 git push",
    "xargs rm /tmp/outside-file", "bash -lc 'cp file /tmp/outside-file'",
  ]) await denied(command);
  await allowed("node script.mjs git push");
  await allowed("rex run 'git push'");
  await allowed("echo git push");
  await allowed("rex whoami --json > /tmp/rex.json");
});

test("direct file tools, AST/LSP mutations, and other tools are unrestricted", async () => {
  for (const toolName of ["write", "edit", "remove", "delete", "powershell", "ast_grep_replace", "lsp_navigation"]) {
    const { result, prompts } = await check({
      path: join(outside, "file"), paths: [outside], apply: true, command: "script",
    }, { toolName, hasUI: true });
    assert.equal(result, undefined, toolName);
    assert.equal(prompts.length, 0, toolName);
  }
});

test("nested calls and namespaced shell tools still enforce denials", async () => {
  const push = { recipient_name: "functions.bash", parameters: { command: "git push" } };
  const write = { recipient_name: "functions.write", parameters: { path: join(outside, "file") } };
  const { result, prompts } = await check({ tool_uses: [write, push] }, {
    toolName: "multi_tool_use.parallel", hasUI: true, approved: true,
  });
  assert.equal(result?.block, true);
  assert.equal(prompts.length, 0);
  await denied("git push");
  assert.equal((await check({ command: "git push" }, { toolName: "functions.bash" })).result?.block, true);
  assert.equal((await check({ code: "await tools.bash(...)" }, { toolName: "codemode" })).result, undefined);
});
