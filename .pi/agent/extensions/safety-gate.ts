/**
 * Repository-scoped workflow guard, not a sandbox.
 * Local file changes are allowed in any Git/jj repo (including ignored files).
 * Explicit commits/remote writes are denied; fetch/pull is handed to the user.
 * Opaque programs and dynamic shell syntax need per-call approval: their write
 * scope cannot be established without executing them. Approval is never cached.
 * Pi's nested tool_call events enforce the same policy inside codemode.
 * Approved opaque programs, installed tools, hooks and configured aliases remain
 * trusted code; this is not protection against deliberate policy evasion.
 */
import { lstatSync, readdirSync, readlinkSync, realpathSync, statSync } from "node:fs";
import { basename, dirname, isAbsolute, join } from "node:path";
import { homedir } from "node:os";

// Structural subset of Pi's extension API; no runtime package dependency.
type Call = { toolName: string; input: Record<string, unknown> };
type Context = {
  cwd: string;
  hasUI: boolean;
  ui: { confirm(title: string, message: string): Promise<boolean> };
};
type Decision = { deny?: string; ask: string[] };
type Result = { block: true; reason: string } | undefined;
type API = {
  on(name: "tool_call", handler: (event: Call, ctx: Context) => Promise<Result>): void;
};
const allow = (): Decision => ({ ask: [] });
const ask = (reason: string): Decision => ({ ask: [reason] });
const deny = (reason: string): Decision => ({ deny: reason, ask: [] });
const record = (value: unknown): value is Record<string, unknown> =>
  value !== null && typeof value === "object" && !Array.isArray(value);

// Resolve each component before '..', including dangling symlinks and new files.
function physicalPath(path: string, depth = 0): string {
  if (depth > 40) throw new Error("Symlink cycle");
  let current = "/";
  for (const part of path.split("/")) {
    if (!part || part === ".") continue;
    if (part === "..") { current = dirname(current); continue; }
    const next = join(current, part);
    try {
      current = realpathSync(next);
    } catch (error) {
      if (!["ENOENT", "ENOTDIR"].includes((error as { code?: string }).code ?? "")) throw error;
      const entry = lstatSync(next, { throwIfNoEntry: false });
      if (entry?.isSymbolicLink()) {
        const destination = readlinkSync(next);
        current = physicalPath(isAbsolute(destination) ? destination : `${current}/${destination}`, depth + 1);
      } else current = next;
    }
  }
  return current;
}

function inRepository(path: string): boolean {
  let directory = path;
  try { if (!statSync(path).isDirectory()) directory = dirname(path); }
  catch { directory = dirname(path); }
  while (true) {
    // .git may be a gitfile in a worktree/submodule. .jj covers standalone jj.
    for (const marker of [".git", ".jj"]) {
      try {
        const entry = statSync(join(directory, marker));
        if (entry.isDirectory() || (marker === ".git" && entry.isFile())) return true;
      } catch { /* Continue to the next ancestor. */ }
    }
    // Bare Git repositories have no .git directory or working tree.
    try {
      if (statSync(join(directory, "HEAD")).isFile() &&
          statSync(join(directory, "objects")).isDirectory() &&
          statSync(join(directory, "refs")).isDirectory()) return true;
    } catch { /* Not a bare repository. */ }
    if (dirname(directory) === directory) return false;
    directory = dirname(directory);
  }
}

function pathDecision(value: unknown, cwd: string): Decision {
  if (typeof value !== "string" || !value) return ask("Unknown write path");
  try {
    const expanded = value.startsWith("~/") ? `${homedir()}/${value.slice(2)}` : value;
    const path = physicalPath(isAbsolute(expanded) ? expanded : `${cwd}/${expanded}`);
    return inRepository(path) ? allow() : ask(`Outside a Git/jj repository: ${value}`);
  } catch {
    return ask(`Cannot resolve write path: ${String(value)}`);
  }
}

// Directory-scoped rewrites/copies may follow descendant symlinks. Ordinary
// removals do not follow them, so only callers that can traverse use this check.
function directoryDecision(value: unknown, cwd: string): Decision {
  const scope = pathDecision(value, cwd);
  if (scope.ask.length || typeof value !== "string") return scope;
  const expanded = value.startsWith("~/") ? `${homedir()}/${value.slice(2)}` : value;
  const pending = [isAbsolute(expanded) ? expanded : `${cwd}/${expanded}`];
  let visited = 0;
  try {
    while (pending.length) {
      const path = pending.pop() ?? "";
      if (!statSync(path, { throwIfNoEntry: false })?.isDirectory()) continue;
      for (const entry of readdirSync(path, { withFileTypes: true })) {
        if (++visited > 5000) return ask("Directory write scope is too broad to inspect");
        const child = join(path, entry.name);
        if (entry.isSymbolicLink()) {
          const target = pathDecision(child, cwd);
          if (target.ask.length) return target;
          // An in-repo link can lead to further links: do not silently trust it.
          if (statSync(child, { throwIfNoEntry: false })?.isDirectory()) return ask("Directory symlink in recursive write scope needs review");
        } else if (entry.isDirectory()) pending.push(child);
      }
    }
    return allow();
  } catch { return ask("Cannot inspect recursive write scope"); }
}

// Deliberately small shell grammar: literal words, quotes, simple pipelines and
// redirections. No interpreter-specific write-API rules or script exceptions.
type Token = { text: string; op: boolean };
function tokenize(source: string): { tokens: Token[]; dynamic: boolean } | undefined {
  const tokens: Token[] = [];
  let word = "", quote = "", started = false, dynamic = false;
  const flush = () => {
    if (started) tokens.push({ text: word, op: false });
    word = ""; started = false;
  };
  for (let i = 0; i < source.length; i++) {
    const char = source[i];
    if (char === "\\" && quote !== "'") {
      const next = source[++i];
      if (next === undefined) return undefined;
      if (next !== "\n") {
        word += quote === '"' && !/[$`"\\]/.test(next) ? "\\" + next : next;
        started = true;
      }
    } else if (quote) {
      if (char === quote) quote = "";
      else {
        if (quote === '"' && /[$`]/.test(char)) dynamic = true;
        word += char;
      }
    } else if (char === "'" || char === '"') {
      quote = char; started = true;
    } else if (/[$`*?{}\[\]~()]/.test(char)) {
      dynamic = true; word += char; started = true;
    } else if (char === "#" && !started) {
      while (i < source.length && source[i] !== "\n") i++;
      flush(); tokens.push({ text: ";", op: true });
    } else if (/\s/.test(char)) {
      flush();
      if (char === "\n") tokens.push({ text: ";", op: true });
    } else if (/[;|&<>]/.test(char)) {
      // Discard descriptor numbers; never mistake them for command names.
      if (/[<>]/.test(char) && /^\d+$/.test(word)) { word = ""; started = false; }
      flush();
      const match = source.slice(i).match(/^(?:[<>]&(?:\d+|-)|&&|\|\||>>|>\||<>|[;|&<>])/);
      if (!match) return undefined;
      const operator = match[0];
      tokens.push({ text: operator, op: true }); i += operator.length - 1;
    } else { word += char; started = true; }
  }
  if (quote) return undefined;
  flush();
  return { tokens, dynamic };
}

const gitReaders = new Set([
  "status", "diff", "log", "show", "blame", "ls-files", "ls-tree", "ls-remote",
  "rev-parse", "rev-list", "describe", "shortlog", "cat-file", "merge-base",
  "for-each-ref", "show-ref", "check-ignore", "check-attr", "help", "version",
  "reflog", "count-objects", "fsck", "verify-commit", "verify-tag",
]);
const gitLocal = new Set([
  "add", "stage", "reset", "restore", "checkout", "switch", "clean", "rm", "mv",
  "branch", "tag", "update-index", "update-ref", "symbolic-ref", "read-tree",
  "write-tree", "prune", "gc", "repack", "pack-refs", "sparse-checkout",
]);
const gitCommits = new Set([
  "commit", "commit-tree", "citool", "merge", "rebase", "cherry-pick", "revert",
  "am", "stash", "filter-branch", "filter-repo", "fast-import", "replay", "notes",
]);
const jjReaders = new Set([
  "status", "st", "diff", "log", "show", "evolog", "evolution-log", "interdiff",
  "root", "help", "version",
]);
const jjLocal = new Set(["restore", "edit", "undo", "redo", "abandon", "file", "bookmark", "b", "tag", "operation", "op", "sparse"]);
const jjCommits = new Set([
  "commit", "ci", "new", "describe", "desc", "metaedit", "duplicate", "split",
  "squash", "absorb", "rebase", "revert", "parallelize", "simplify-parents",
  "converge", "arrange", "sign", "unsign", "next", "prev",
]);
const handoff = "Fetch/pull/clone is user-run: give the user the exact command and wait for them to run it (a security key may be required). Do not retry.";

function vcsDecision(tool: string, args: string[], cwd: string): Decision {
  let directory = cwd;
  const questions: string[] = [];
  const valued = tool === "git"
    ? ["-C", "--git-dir", "--work-tree", "--namespace", "-c", "--config-env", "--exec-path"]
    : ["-R", "--repository", "--at-operation", "--at-op", "--color", "--config", "--config-file"];
  let i = 0;
  for (; i < args.length && args[i].startsWith("-"); i++) {
    const arg = args[i];
    const option = valued.find((key) => arg === key || arg.startsWith(key + "=") || (["-C", "-R", "-c"].includes(key) && arg.startsWith(key) && arg.length > 2));
    if (!option) {
      if (!["--no-pager", "--paginate", "--no-optional-locks", "--literal-pathspecs", "--ignore-working-copy", "--ignore-immutable", "--quiet", "--debug", "--no-integrate-operation"].includes(arg)) {
        questions.push(`Unrecognized ${tool} option: ${arg}`);
      }
      continue;
    }
    const value = arg === option ? args[++i] : arg.slice(option.length).replace(/^=/, "");
    if (!value) return ask(`Missing ${tool} option value`);
    if (["-C", "-R", "--repository", "--work-tree"].includes(option)) directory = physicalPath(isAbsolute(value) ? value : `${directory}/${value}`);
    else if (!["--at-operation", "--at-op", "--color", "--namespace"].includes(option)) questions.push(`${tool} configuration or alternate storage override`);
  }
  const words = args.slice(i);
  const [sub = "", second = ""] = words;
  if (!sub || sub === "help" || (words.length === 2 && ["--help", "-h"].includes(second)) || sub === "--version") return allow();
  if (tool === "git") {
    if (["push", "send-pack", "http-push", "receive-pack", "cvsexportcommit"].includes(sub)) return deny("Remote repository writes are not allowed");
    if (["fetch", "pull", "clone", "fetch-pack"].includes(sub) || (sub === "remote" && second === "update")) return deny(handoff);
    if ((sub === "subtree" && second === "push") || (sub === "svn" && second === "dcommit") || (sub === "lfs" && second === "push") || (sub === "p4" && second === "submit")) return deny("Remote repository writes are not allowed");
    if ((sub === "submodule" && ["add", "update"].includes(second)) || (sub === "lfs" && ["fetch", "pull"].includes(second))) return deny(handoff);
    if (gitCommits.has(sub)) {
      const inspection = (sub === "stash" && ["list", "show", "drop", "clear", "apply", "pop"].includes(second)) ||
        (sub === "notes" && ["", "list", "show", "get-ref"].includes(second));
      // Require these switches in command position, not e.g. as a -m value.
      const noCommit = ["merge", "cherry-pick", "revert"].includes(sub) && second === "--no-commit" && !words.some((word) => ["--continue", "--commit"].includes(word));
      const abort = ["merge", "rebase", "cherry-pick", "revert", "am"].includes(sub) && words.length === 2 && ["--abort", "--quit"].includes(second);
      if (!inspection && !noCommit && !abort) return deny("Creating or rewriting commits is not allowed");
    }
  } else {
    if ((sub === "git" && second === "push") || (sub === "gerrit" && second === "push")) return deny("Remote repository writes are not allowed");
    if (sub === "git" && ["fetch", "clone"].includes(second)) return deny(handoff);
    if (jjCommits.has(sub)) return deny("Creating or rewriting commits is not allowed (automatic working-copy snapshots are permitted)");
  }
  // Explicit output and external execution options aren't ordinary local VCS.
  if (words.some((word) => /^(?:--output|--exec|--ext-diff|--textconv|--tool|--editor|--upload-pack|--receive-pack)(?:=|$)/.test(word))) questions.push("VCS output or external program needs review");
  let known = tool === "git"
    ? gitReaders.has(sub) || gitLocal.has(sub) || gitCommits.has(sub) || sub === "remote"
    : jjReaders.has(sub) || jjLocal.has(sub) || (sub === "git" && ["root", "import", "export", "remote"].includes(second));
  if (sub === "config") {
    known = tool === "git"
      ? ["list", "get", "--list", "-l", "--get", "--get-all", "--get-regexp"].includes(second)
      : ["list", "get", "path"].includes(second);
    if (words.some((word) => /^(?:--global|--system|--file|-f|--edit|-e|--unset|--add|--replace-all)(?:=|$)/.test(word))) known = false;
  }
  if (!known) questions.push(`Unknown ${tool} command/alias or write scope: ${words.join(" ")}`);
  const readOnly = tool === "git" ? gitReaders.has(sub) : jjReaders.has(sub);
  if (!readOnly) questions.push(...pathDecision(directory, cwd).ask);
  return { ask: questions };
}

const readers = new Set(["ls", "pwd", "rg", "grep", "egrep", "fgrep", "find", "head", "tail", "cat", "wc", "stat", "file", "readlink", "realpath", "which", "command", "type", "date", "uname", "echo", "printf", "true", "false", "test", "sort", "uniq", "cut", "tr", "du"]);
const fileWriters = new Set(["rm", "rmdir", "unlink", "mkdir", "touch", "truncate", "tee", "chmod", "chown"]);

function shellDecision(source: string, cwd: string, depth = 0): Decision {
  if (depth > 8) return ask("Nested shell depth exceeds inspection limit");
  const parsed = tokenize(source);
  if (!parsed) return ask("Unsupported shell syntax; write scope needs review");
  const { tokens, dynamic } = parsed;
  const decisions: Decision[] = dynamic ? [ask("Dynamic shell syntax; write scope needs review")] : [];
  if (tokens.some((token) => !token.op && token.text === "cd") &&
      tokens.some((token) => token.op && ["||", "|", "&"].includes(token.text))) {
    decisions.push(ask("Conditional or concurrent directory changes need review"));
  }
  let directory = cwd;
  const groups: Token[][] = [[]];
  for (const token of tokens) {
    if (token.op && [";", "&&", "||", "|", "&"].includes(token.text)) groups.push([]);
    else groups[groups.length - 1].push(token);
  }
  for (const group of groups) {
    const words: string[] = [];
    for (let i = 0; i < group.length; i++) {
      const token = group[i];
      if (!token.op) { words.push(token.text); continue; }
      if (/^[<>]&(?:\d+|-)$/.test(token.text)) continue;
      const target = group[++i];
      if (!target || target.op || token.text === "<>") decisions.push(ask("Unsupported redirection"));
      else if (token.text.includes(">") && target.text !== "/dev/null") decisions.push(pathDecision(target.text, directory));
    }
    // Inspect normal command/env wrappers without interpreting assignment values.
    while (words.length && ((words[0] === "command" && !["-v", "-V"].includes(words[1])) || words[0] === "env" || /^[A-Za-z_][A-Za-z_0-9]*=/.test(words[0]))) {
      const wrapper = words.shift()!;
      if (wrapper.includes("=")) decisions.push(ask("Environment override needs review"));
      if (words[0] === "--") words.shift();
    }
    const name = basename(words.shift() ?? "");
    if (!name) continue;
    if (name === "cd") {
      if (words.length !== 1 || words[0].startsWith("-")) decisions.push(ask("Unknown directory change"));
      else directory = physicalPath(isAbsolute(words[0]) ? words[0] : `${directory}/${words[0]}`);
    } else if (name === "git" || name === "jj") {
      decisions.push(vcsDecision(name, words, directory));
    } else if (["sh", "bash", "zsh", "dash", "ksh"].includes(name) && /^-[a-z]*c[a-z]*$/.test(words[0] ?? "") && words.length === 2) {
      decisions.push(shellDecision(words[1], directory, depth + 1));
    } else if (fileWriters.has(name) || ["cp", "mv", "ln"].includes(name)) {
      // Checking all operands is conservative (cp sources need not be writable).
      if (words.some((word) => /^--[^=]+=/.test(word) || /^-[^-].{1,}/.test(word) && !/^-[rfpvisfnvRLHP]+$/.test(word))) {
        decisions.push(ask("Mutation options with attached values need review"));
      }
      const paths = words.filter((word) => !word.startsWith("-"));
      if (!paths.length) decisions.push(ask("Missing mutation path"));
      for (const path of paths) decisions.push(name === "cp" ? directoryDecision(path, directory) : pathDecision(path, directory));
    } else if (readers.has(name)) {
      if (name === "sort") {
        for (let i = 0; i < words.length; i++) {
          if (["-o", "--output"].includes(words[i])) decisions.push(pathDecision(words[++i], directory));
          else if (words[i].startsWith("--output=")) decisions.push(pathDecision(words[i].slice(9), directory));
          else if (/^-o./.test(words[i])) decisions.push(pathDecision(words[i].slice(2), directory));
        }
      }
      if (name === "file" && words.some((word) => word === "-C" || word === "--compile")) decisions.push(ask("Compiling a magic file writes output"));
      if ((name === "find" && words.some((word) => /^-(?:delete|exec|execdir|ok|okdir|fprint|fprintf|fls)/.test(word))) ||
          (name === "rg" && words.some((word) => /^--(?:pre|hostname-bin)(?:=|$)/.test(word)))) decisions.push(ask("Search command can write or execute programs"));
    } else {
      // Catch ordinary wrappers (sudo, timeout, xargs, etc.) without treating
      // reader arguments such as `echo git push` as executable commands.
      for (let i = 0; i < words.length; i++) {
        const nested = basename(words[i]);
        if (nested === "git" || nested === "jj") decisions.push(vcsDecision(nested, words.slice(i + 1), directory));
      }
      decisions.push(ask(`Opaque command (${name}); cannot establish repository-only writes`));
    }
  }
  return combine(decisions);
}

function combine(decisions: Decision[]): Decision {
  return { deny: decisions.find((decision) => decision.deny)?.deny, ask: decisions.flatMap((decision) => decision.ask) };
}

function callDecision(event: Call, cwd: string): Decision {
  const name = event.toolName.split(".").pop() ?? event.toolName;
  const input = event.input;
  if (Array.isArray(input.tool_uses)) {
    const decisions: Decision[] = [];
    for (const call of input.tool_uses) {
      if (!record(call)) continue;
      const nestedInput = call.parameters ?? call.arguments;
      decisions.push(callDecision({
        toolName: String(call.recipient_name ?? call.name ?? ""),
        input: record(nestedInput) ? nestedInput : {},
      }, cwd));
    }
    return combine(decisions);
  }
  if (name === "powershell") return ask("PowerShell write scope needs review");
  if (["bash", "shell", "hypa_shell"].includes(name)) {
    const command = input.command ?? input.cmd ?? input.script;
    return typeof command === "string" ? shellDecision(command, cwd) : ask("Missing shell command");
  }
  if (["write", "edit", "remove", "delete"].includes(name)) return pathDecision(input.path, cwd);
  if ((name === "ast_grep_replace" || name === "lsp_navigation") && input.apply === true) {
    const paths = input.paths ?? (input.path ? [input.path] : []);
    const decisions: Decision[] = [];
    if (!Array.isArray(paths) || !paths.length) decisions.push(ask("Unknown mutation scope"));
    else for (const path of paths) {
      if (typeof path === "string" && /[*?{}\[\]]/.test(path)) decisions.push(ask("Globbed mutation scope needs review"));
      else decisions.push(directoryDecision(path, cwd));
    }
    if (input.newFilePath) decisions.push(pathDecision(input.newFilePath, cwd));
    return combine(decisions);
  }
  // Orchestrators are allowed here: actual nested calls emit tool_call events.
  // Other tools aren't classified by names/guessed side effects.
  return allow();
}

export default function safetyGate(pi: API): void {
  pi.on("tool_call", async (event, ctx) => {
    let decision: Decision;
    try { decision = callDecision(event, ctx.cwd); }
    catch { decision = ask("Safety gate could not establish this call's write scope"); }
    if (decision.deny) return { block: true, reason: decision.deny };
    if (!decision.ask.length) return undefined;
    const reasons = [...new Set(decision.ask)].join("\n");
    const message = `${event.toolName}\n${reasons}\n\n${JSON.stringify(event.input, null, 2)}`;
    if (!ctx.hasUI) return { block: true, reason: `Approval required (no UI): ${reasons}` };
    if (!(await ctx.ui.confirm("Safety gate: approve this call?", message))) return { block: true, reason: `Not approved: ${reasons}` };
    return undefined;
  });
}
