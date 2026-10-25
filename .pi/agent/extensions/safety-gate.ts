/**
 * Lightweight deny-only workflow guard, not a sandbox.
 * Block gh, recognized remote Git/jj operations, commit/history creation, and
 * rm/cp writes outside Git/jj repositories. No approval prompts.
 * Aliases, configuration overrides, scripts and opaque programs are trusted;
 * this does not inspect their contents or prevent deliberate policy evasion.
 */
import { lstatSync, readdirSync, readlinkSync, realpathSync, statSync } from "node:fs";
import { basename, dirname, isAbsolute, join } from "node:path";
import { homedir } from "node:os";

// Structural subset of Pi's extension API; no runtime package dependency.
type Call = { toolName: string; input: Record<string, unknown> };
type Context = {
  cwd: string;
};
type Decision = { deny?: string };
type Result = { block: true; reason: string } | undefined;
type API = {
  on(name: "tool_call", handler: (event: Call, ctx: Context) => Promise<Result>): void;
};
const allow = (): Decision => ({});
const deny = (reason: string): Decision => ({ deny: reason });
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
  if (typeof value !== "string" || !value) return deny("Unknown write path");
  try {
    const expanded = value.startsWith("~/") ? `${homedir()}/${value.slice(2)}` : value;
    const path = physicalPath(isAbsolute(expanded) ? expanded : `${cwd}/${expanded}`);
    return inRepository(path) ? allow() : deny(`Outside a Git/jj repository: ${value}`);
  } catch {
    return deny(`Cannot resolve write path: ${String(value)}`);
  }
}

// Directory-scoped rewrites/copies may follow descendant symlinks. Ordinary
// removals do not follow them, so only callers that can traverse use this check.
function directoryDecision(value: unknown, cwd: string): Decision {
  const scope = pathDecision(value, cwd);
  if (scope.deny || typeof value !== "string") return scope;
  const expanded = value.startsWith("~/") ? `${homedir()}/${value.slice(2)}` : value;
  const pending = [isAbsolute(expanded) ? expanded : `${cwd}/${expanded}`];
  let visited = 0;
  try {
    while (pending.length) {
      const path = pending.pop() ?? "";
      if (!statSync(path, { throwIfNoEntry: false })?.isDirectory()) continue;
      for (const entry of readdirSync(path, { withFileTypes: true })) {
        if (++visited > 5000) return deny("Directory write scope is too broad to inspect");
        const child = join(path, entry.name);
        if (entry.isSymbolicLink()) {
          const target = pathDecision(child, cwd);
          if (target.deny) return target;
          // An in-repo link can lead to further links: do not silently trust it.
          if (statSync(child, { throwIfNoEntry: false })?.isDirectory()) return deny("Directory symlink in recursive write scope cannot be safely inspected");
        } else if (entry.isDirectory()) pending.push(child);
      }
    }
    return allow();
  } catch { return deny("Cannot inspect recursive write scope"); }
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

const gitCommits = new Set([
  "commit", "commit-tree", "citool", "merge", "rebase", "cherry-pick", "revert",
  "am", "stash", "filter-branch", "filter-repo", "fast-import", "replay", "notes",
]);
const jjCommits = new Set([
  "commit", "ci", "new", "describe", "desc", "metaedit", "duplicate", "split",
  "squash", "absorb", "rebase", "revert", "parallelize", "simplify-parents",
  "converge", "arrange", "sign", "unsign", "next", "prev",
]);
const remoteCommands = new Set([
  "push", "fetch", "pull", "clone", "ls-remote", "send-pack", "fetch-pack",
  "http-push", "receive-pack", "upload-pack", "upload-archive", "cvsexportcommit",
  "daemon",
]);
const remoteDenied = () => deny("Remote Git/jj operations are user-run; do not retry through another tool");

function vcsDecision(tool: string, args: string[]): Decision {
  // Skip global options and their values to find the explicit subcommand.
  // Configuration overrides are allowed, but their contents are not inspected.
  const valued = tool === "git"
    ? ["-C", "--git-dir", "--work-tree", "--namespace", "-c", "--config-env", "--exec-path"]
    : ["-R", "--repository", "--at-operation", "--at-op", "--color", "--config", "--config-file"];
  let i = 0;
  for (; i < args.length && args[i].startsWith("-"); i++) {
    if (valued.includes(args[i])) i++;
  }
  const words = args.slice(i);
  const [sub = "", second = ""] = words;
  if (!sub || sub === "help" || (words.length === 2 && ["--help", "-h"].includes(second))) return allow();
  if (tool === "git") {
    if (remoteCommands.has(sub) || ["svn", "p4"].includes(sub) ||
        words.some((word) => word === "--remote" || word.startsWith("--remote=")) ||
        (sub === "remote" && ["update", "show", "prune"].includes(second)) ||
        (sub === "subtree" && ["push", "pull", "add"].includes(second)) ||
        (sub === "submodule" && ["add", "update"].includes(second)) ||
        (sub === "lfs" && remoteCommands.has(second))) return remoteDenied();
    if (gitCommits.has(sub)) {
      const inspection = (sub === "stash" && ["list", "show", "drop", "clear", "apply", "pop"].includes(second)) ||
        (sub === "notes" && ["", "list", "show", "get-ref"].includes(second));
      const noCommit = ["merge", "cherry-pick", "revert"].includes(sub) && second === "--no-commit" &&
        !words.some((word) => ["--continue", "--commit"].includes(word));
      const abort = ["merge", "rebase", "cherry-pick", "revert", "am"].includes(sub) &&
        words.length === 2 && ["--abort", "--quit"].includes(second);
      if (!inspection && !noCommit && !abort) return deny("Creating or rewriting commits is not allowed");
    }
  } else {
    if ((sub === "git" || sub === "gerrit") && remoteCommands.has(second)) return remoteDenied();
    if (jjCommits.has(sub)) return deny("Creating or rewriting commits is not allowed (automatic working-copy snapshots are permitted)");
  }
  return allow();
}

// Only these wrappers are inspected. Opaque programs and their arguments are
// otherwise trusted, so e.g. echo/node/rex arguments are not treated as commands.
const wrappers = new Set(["command", "env", "sudo", "timeout", "xargs", "nice", "nohup"]);

function mutationDecision(name: string, words: string[], cwd: string | undefined, dynamic: boolean): Decision {
  if (!cwd || dynamic) return deny(`Cannot establish repository scope for ${name}`);
  const paths: string[] = [];
  let destination: string | undefined;
  let options = true;
  for (let i = 0; i < words.length; i++) {
    const word = words[i];
    if (options && word === "--") { options = false; continue; }
    if (options && name === "cp" && ["-t", "--target-directory"].includes(word)) {
      destination = words[++i];
      if (!destination) return deny("Missing copy destination");
    } else if (options && name === "cp" && word.startsWith("--target-directory=")) {
      destination = word.slice(19);
    } else if (options && name === "cp" && /^-t./.test(word)) {
      destination = word.slice(2);
    } else if (options && word.startsWith("-")) {
      // Avoid mistaking option values (e.g. BSD cp -S suffix) for paths.
      if (!/^-[rfipPRHLavnsvdflxT]+$/.test(word) &&
          !["--recursive", "--force", "--interactive", "--preserve", "--no-clobber", "--verbose", "--archive", "--no-target-directory"].includes(word)) {
        return deny(`Cannot establish ${name} scope with option: ${word}`);
      }
    } else paths.push(word);
  }
  if (name === "rm") return combine(paths.map((path) => pathDecision(path, cwd)));
  const target = destination ?? paths.pop();
  if (!target) return deny("Missing copy destination");
  const decisions = [directoryDecision(target, cwd)];
  // cp into a directory writes source basenames, which may themselves be symlinks.
  const expanded = target.startsWith("~/") ? `${homedir()}/${target.slice(2)}` : target;
  const targetPath = isAbsolute(expanded) ? expanded : `${cwd}/${expanded}`;
  if (statSync(targetPath, { throwIfNoEntry: false })?.isDirectory()) {
    for (const source of paths) decisions.push(directoryDecision(join(targetPath, basename(source)), cwd));
  }
  return combine(decisions);
}

function shellDecision(source: string, cwd: string, depth = 0): Decision {
  if (depth > 8) return allow();
  const parsed = tokenize(source);
  if (!parsed) return allow();
  const decisions: Decision[] = [];
  let directory: string | undefined = cwd;
  const isDynamic = (word: string) => [...word].some((char) => "$`*?{}[]".includes(char));
  const uncertainCd = parsed.tokens.some((token) => !token.op && token.text === "cd") &&
    parsed.tokens.some((token) => token.op && ["||", "|", "&"].includes(token.text));
  const groups: Token[][] = [[]];
  for (const token of parsed.tokens) {
    if (token.op && [";", "&&", "||", "|", "&"].includes(token.text)) groups.push([]);
    else groups[groups.length - 1].push(token);
  }
  for (const group of groups) {
    const words: string[] = [];
    for (let i = 0; i < group.length; i++) {
      if (!group[i].op) words.push(group[i].text);
      else if (!/^[<>]&(?:\d+|-)$/.test(group[i].text)) i++;
    }
    while (/^[A-Za-z_][A-Za-z_0-9]*=/.test(words[0] ?? "")) words.shift();
    let name = basename(words.shift() ?? "");
    while (wrappers.has(name)) {
      if (name === "command" && ["-v", "-V"].includes(words[0])) { name = ""; break; }
      const index = words.findIndex((word) =>
        ["git", "jj", "gh", "rm", "cp", "sh", "bash", "zsh", "dash", "ksh"].includes(basename(word)));
      if (index < 0) { name = ""; break; }
      words.splice(0, index);
      name = basename(words.shift() ?? "");
    }
    if (name === "cd") {
      if (uncertainCd || words.length !== 1 || isDynamic(words[0])) directory = undefined;
      else {
        try {
          const path = words[0].startsWith("~/") ? `${homedir()}/${words[0].slice(2)}` : words[0];
          if (isAbsolute(path)) directory = physicalPath(path);
          else if (directory) directory = physicalPath(`${directory}/${path}`);
        } catch { directory = undefined; }
      }
    } else if (name === "gh") {
      decisions.push(deny("All gh commands are user-run"));
    } else if (name === "git" || name === "jj") {
      decisions.push(vcsDecision(name, words));
    } else if (["sh", "bash", "zsh", "dash", "ksh"].includes(name) && /^-[a-z]*c[a-z]*$/.test(words[0] ?? "") && words.length === 2) {
      decisions.push(shellDecision(words[1], directory ?? cwd, depth + 1));
    } else if (name === "rm" || name === "cp") {
      decisions.push(mutationDecision(name, words, directory, words.some(isDynamic)));
    }
  }
  return combine(decisions);
}

function combine(decisions: Decision[]): Decision {
  return { deny: decisions.find((decision) => decision.deny)?.deny };
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
  if (["bash", "shell", "hypa_shell"].includes(name)) {
    const command = input.command ?? input.cmd ?? input.script;
    return typeof command === "string" ? shellDecision(command, cwd) : allow();
  }
  // Orchestrators are allowed here: actual nested calls emit tool_call events.
  // Other tools aren't classified by names/guessed side effects.
  return allow();
}

export default function safetyGate(pi: API): void {
  pi.on("tool_call", async (event, ctx) => {
    let decision: Decision;
    try { decision = callDecision(event, ctx.cwd); }
    catch { return { block: true, reason: "Cannot inspect protected command scope" }; }
    return decision.deny ? { block: true, reason: decision.deny } : undefined;
  });
}
