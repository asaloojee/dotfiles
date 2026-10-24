import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { after, test } from "node:test";
import safetyGate from "../extensions/safety-gate.ts";

// No repository-changing commands under test are executed. Only fixture init is.
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

test("ordinary Git/jj inspection and local changes don't prompt", async () => {
  for (const command of [
    "git status --short", "git log -5", "git diff --staged", "git ls-remote origin",
    "git reset --hard HEAD", "git clean -fd", "git checkout -- src/file.ts",
    "git restore --worktree src/file.ts", "git add ignored/file", "git rm src/file.ts",
    "git branch -D old", "git tag -d old", "git remote set-url origin new-url",
    "git stash list", "git stash show", "git stash drop", "git stash apply",
    "git merge --abort", "git rebase --abort", "git cherry-pick --no-commit abc",
    "git revert --no-commit abc", "git merge --no-commit --no-ff branch",
    "jj status", "jj st", "jj log", "jj diff", "jj restore src/file.ts",
    "jj undo", "jj op restore operation", "jj bookmark delete old", "jj file untrack file",
    "jj git export", "jj git import", "jj git remote list",
    "git --no-pager log", "jj --ignore-working-copy status",
    "echo 'git push'", "printf '%s' 'jj commit'", "command -v git",
  ]) await allowed(command);
});

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

test("fetch/pull/clone hand off to the user without approval or retries", async () => {
  for (const command of [
    "git fetch", "git fetch --all", "git pull --ff-only", "git clone url",
    "git fetch-pack url", "git remote update", "jj git fetch", "jj git clone url",
    "git submodule update --init", "git submodule add url", "git lfs pull",
    "bash -lc 'git pull'", "git -C . fetch origin",
  ]) await denied(command, /user-run.*security key.*Do not retry/);
});

test("tracked, untracked, ignored, metadata and other repository files are writable", async () => {
  for (const cwd of [repo, outside]) {
    for (const path of [join(repo, "src/file.ts"), join(repo, "new/nested/file"), join(repo, "ignored/file"), join(repo, ".env"), join(repo, ".git/config"), join(repo, "literal[$file].txt"), join(other, "new/file"), join(standalone, "new/file")]) {
      for (const toolName of ["write", "edit", "remove"]) {
        const { result, prompts } = await check({ path, content: "new" }, { cwd, toolName });
        assert.equal(result, undefined, `${toolName}: ${path}`);
        assert.equal(prompts.length, 0);
      }
    }
  }
  await allowed(`rm -rf '${other}/new'`);
  await allowed("touch ignored/file; mkdir -p new/dir; rm -rf src");
  await allowed("printf '%s' text > new/file");
  await allowed("echo text 2> ignored/log");
  await allowed("git status 2>&1");
  await allowed("git status >/dev/null");
});

test("outside-repository changes require per-call approval and fail closed without UI", async () => {
  for (const input of [{ path: join(outside, "new/file"), content: "new" }, { path: "file", content: "new" }]) {
    for (const approved of [false, true]) {
      const { result, prompts } = await check(input, { cwd: outside, toolName: "write", hasUI: true, approved });
      assert.equal(result?.block, approved ? undefined : true);
      assert.equal(prompts.length, 1);
      assert.match(prompts[0].message, /Outside a Git\/jj repository/);
    }
    const { result } = await check(input, { cwd: outside, toolName: "write", approved: true });
    assert.equal(result?.block, true);
  }
  for (const command of [
    `rm -rf '${outside}/file'`, `touch '${outside}/file'`, `echo text > '${outside}/file'`,
    `mv src/file.ts '${outside}/file'`, `cp src/file.ts '${outside}/file'`,
    `cp --target-directory='${outside}' src/file.ts`, `cp -t'${outside}' src/file.ts`,
    `cd '${outside}' && touch file`, `sort src/file.ts -o '${outside}/sorted'`,
    `sort --output='${outside}/sorted' src/file.ts`, `sort -o'${outside}/sorted' src/file.ts`,
  ]) {
    const { result, prompts } = await check({ command }, { hasUI: true, approved: true });
    assert.equal(result, undefined, command);
    assert.equal(prompts.length, 1, command);
    assert.equal((await check({ command })).result?.block, true, command);
  }
});

test("symlinks, dangling targets and symlink/.. paths use physical repository scope", async () => {
  for (const path of ["escape/file", "dangling", "dangling/new/file", "relative-dangling/new/file", "escape/../file"]) {
    assert.equal((await check({ path }, { toolName: "write" })).result?.block, true, path);
  }
  for (const path of [join(outside, "into-repo/file"), join(repo, "src/../new/file")]) {
    assert.equal((await check({ path }, { toolName: "write" })).result, undefined, path);
  }
  assert.equal((await check({ command: "cd escape/.. && touch file" })).result?.block, true);
});

test("Git worktree gitfiles and standalone jj roots are recognized", async () => {
  const worktree = join(base, "worktree");
  mkdirSync(worktree);
  writeFileSync(join(worktree, ".git"), `gitdir: ${repo}/.git/worktrees/fixture\n`);
  await allowed("touch new/file", { cwd: worktree });
  await allowed("touch new/file", { cwd: standalone });
  const bare = join(base, "bare");
  execFileSync("git", ["init", "-q", "--bare", bare]);
  await allowed("touch info/local-note", { cwd: bare });
});

test("directory changes and VCS repository overrides use their actual scope", async () => {
  await allowed(`cd '${other}' && touch file`);
  await allowed(`git -C '${other}' reset --hard`);
  await allowed(`jj --repository '${standalone}' restore file`);
  await allowed("git status", { cwd: outside });
  assert.equal((await check({ command: `git --work-tree '${outside}' reset --hard` })).result?.block, true);
  assert.equal((await check({ command: `cd '${outside}' || cd '${repo}'; touch file` })).result?.block, true);
});

test("opaque scripts, aliases and dynamic scope prompt without language-specific exceptions", async () => {
  for (const command of [
    "python -c 'from pathlib import Path; Path(\"file\").write_text(\"new\")'",
    "node rewrite.mjs", "ruby rewrite.rb", "./rewrite.sh", "git custom-alias",
    "touch $TARGET", "rm *.ts", "echo $(pwd) > file", "bash rewrite.sh",
    "find . -delete", "find . -exec rm {} +", "find . -fls /tmp/list",
    "rg --pre script pattern", "git diff --output=/tmp/patch", "git -c alias.test=status test",
  ]) {
    const { result, prompts } = await check({ command }, { hasUI: true, approved: true });
    assert.equal(result, undefined, command);
    assert.equal(prompts.length, 1, command);
    assert.equal((await check({ command })).result?.block, true, command);
  }
});

test("codemode delegates to nested tool_call enforcement; namespaced tools match", async () => {
  assert.equal((await check({ code: "await tools.bash({command: 'git push'})" }, { toolName: "codemode" })).result, undefined);
  await denied("git push");
  const { result } = await check({ command: "git push" }, { toolName: "vendor.functions.bash", approved: true, hasUI: true });
  assert.equal(result?.block, true);
  assert.equal((await check({ path: join(outside, "file") }, { toolName: "functions.edit" })).result?.block, true);
});

test("batch denials take priority over approval, regardless of order or nesting", async () => {
  const write = { recipient_name: "functions.write", parameters: { path: join(outside, "file"), content: "new" } };
  const push = { recipient_name: "functions.bash", parameters: { command: "git push" } };
  for (const calls of [[write, push], [push, write]]) {
    const input = { tool_uses: [{ name: "wrapper", arguments: { tool_uses: calls } }] };
    const { result, prompts } = await check(input, { toolName: "multi_tool_use.parallel", hasUI: true, approved: true });
    assert.equal(result?.block, true);
    assert.equal(prompts.length, 0);
  }
});

test("structured AST/LSP writes check every path and rename destination", async () => {
  for (const toolName of ["ast_grep_replace", "lsp_navigation"]) {
    assert.equal((await check({ apply: true, paths: ["src"] }, { toolName })).result, undefined);
    assert.equal((await check({ apply: false, paths: [outside] }, { toolName })).result, undefined);
    assert.equal((await check({ apply: true, paths: ["src", outside] }, { toolName })).result?.block, true);
    assert.equal((await check({ apply: true }, { toolName })).result?.block, true);
    assert.equal((await check({ apply: true, paths: ["src/**/*.ts"] }, { toolName })).result?.block, true);
  }
  assert.equal((await check({ apply: true, path: "src/file.ts", newFilePath: join(outside, "file.ts") }, { toolName: "lsp_navigation" })).result?.block, true);
});

test("recursive writes inspect descendant symlinks; removals can safely unlink them", async () => {
  const directory = join(repo, "with-links");
  mkdirSync(directory);
  symlinkSync(outside, join(directory, "outside"));
  assert.equal((await check({ apply: true, paths: [directory] }, { toolName: "ast_grep_replace" })).result?.block, true);
  assert.equal((await check({ command: "cp -R src with-links" })).result?.block, true);
  await allowed("rm -rf with-links");
});

test("approval is not cached between calls", async () => {
  let handler;
  safetyGate({ on(_name, callback) { handler = callback; } });
  let prompts = 0;
  const ctx = { cwd: repo, hasUI: true, ui: { async confirm() { return ++prompts === 1; } } };
  const call = { toolName: "write", input: { path: join(outside, "file") } };
  assert.equal(await handler(call, ctx), undefined);
  assert.equal((await handler(call, ctx))?.block, true);
  assert.equal(prompts, 2);
});
