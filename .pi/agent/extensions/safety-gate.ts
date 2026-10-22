/**
 * Allow routine workspace changes; confirm protected paths and unclear commands.
 * Sensitive Git/jj operations are blocked, even with UI approval.
 * Heuristic workflow guard only: arbitrary programs and aliases are not sandboxed.
 */
import { lstatSync, readdirSync, readlinkSync, realpathSync, statSync } from "node:fs";
import { basename, dirname, isAbsolute, relative, resolve } from "node:path";

type ToolCallEvent = { toolName: string; input: Record<string, unknown> };
type ToolCallContext = {
  hasUI: boolean;
  cwd?: string;
  ui: { confirm(title: string, message: string): Promise<boolean> };
};
type ToolCallResult = { block: true; reason: string } | undefined;
type ExtensionAPI = {
  on(
    eventName: "tool_call",
    handler: (
      event: ToolCallEvent,
      ctx: ToolCallContext,
    ) => ToolCallResult | Promise<ToolCallResult>,
  ): void;
};

type Rule = { name: string; pattern: RegExp };
const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === "object" && value !== null && !Array.isArray(value);

const getToolInput = (value: unknown): Record<string, unknown> => (isRecord(value) ? value : {});

const getCommand = (input: Record<string, unknown>) => {
  for (const key of ["command", "cmd", "script"]) {
    const value = input[key];
    if (typeof value === "string") return value;
  }
  return "";
};

// Flatten once, retaining the original name for approval messages.
const collectToolCalls = (event: ToolCallEvent): (ToolCallEvent & { name: string })[] => {
  const calls = [{ ...event, name: event.toolName.split(".").pop() ?? event.toolName }];
  const nestedTools = event.input.tool_uses;
  if (!Array.isArray(nestedTools)) return calls;
  for (const nested of nestedTools) {
    if (!isRecord(nested)) continue;
    const toolName = String(nested.recipient_name ?? nested.name ?? "");
    if (toolName) calls.push(...collectToolCalls({
      toolName,
      input: getToolInput(nested.parameters ?? nested.arguments),
    }));
  }
  return calls;
};

// Split a Python call at top-level commas without hiding nested expressions from
// the mutation checks. Unsupported syntax is left gated rather than guessed at.
const getCallArguments = (source: string): string[] | undefined => {
  const stack = ["("];
  const args: string[] = [];
  let start = 0;
  let quote = "";
  for (let index = 0; index < source.length; index++) {
    const char = source[index];
    if (quote) {
      if (char === "\\") index++;
      else if (char === quote) quote = "";
      continue;
    }
    if (char === "#" || char === "\\") return undefined;
    if (char === "'" || char === '"') {
      if (source.slice(index, index + 3) === char.repeat(3)) return undefined;
      quote = char;
    } else if ("([{".includes(char)) {
      stack.push(char);
    } else if (")]}".includes(char)) {
      const opening = stack.pop();
      if (opening !== { ")": "(", "]": "[", "}": "{" }[char]) return undefined;
      if (stack.length === 0) {
        const last = source.slice(start, index).trim();
        if (last) args.push(last);
        return args;
      }
    } else if (char === "," && stack.length === 1) {
      args.push(source.slice(start, index).trim());
      start = index + 1;
    }
  }
  return undefined;
};

const maskBashSyntaxChecks = (code: string): string => {
  let matched = false;
  const masked = code.replace(/\bsubprocess\.run\s*\(/g, (callee, offset: number) => {
    const args = getCallArguments(code.slice(offset + callee.length));
    if (
      args?.length !== 3 ||
      !/^\[\s*(["'])bash\1\s*,\s*(["'])-n\2\s*\]$/.test(args[0]) ||
      !args.slice(1).some((arg) => /^input\s*=\s*\S/.test(arg)) ||
      !args.slice(1).some((arg) => /^text\s*=\s*True$/.test(arg))
    )
      return callee;
    matched = true;
    return "_bashSyntaxCheck(";
  });
  // Only the plain import is exempt. Aliases, other calls, and attribute access
  // retain the subprocess marker and therefore still require confirmation.
  return matched
    ? masked.replace(/\bimport[ \t]+subprocess(?=[ \t]*(?:;|\n))/g, "import _bashSyntaxCheckModule")
    : masked;
};

// Keep opaque scripts/modules gated, but do not treat every interpreter invocation as a write.
// Inline code is checked for common write APIs and indirect execution below.
const getScriptRisk = (command: string): string | undefined => {
  const interpreters =
    /(?:^|[\s;|&()])(?:[^\s]+\/)?(python[\d.]*|node|ruby|perl|php|bun|deno)\b([^\n;|&]*)/gi;
  for (const match of command.matchAll(interpreters)) {
    const args = match[2].trim();
    if (/^(?:--version|-V|-v)(?:\s*$)/.test(args.replace(/\s+\d*>.*$/, ""))) continue;
    const inline = args.match(/^(?:-c|-e|-r|--eval(?:=|\s)|eval\s)\s*(['"])/);
    if (!inline) return "script/module execution requiring review";
    if (inline[1] === '"' && /\$|`/.test(args)) {
      return "dynamically generated script requiring review";
    }

    // stdout/stderr writes are output, not file mutation.
    const code = maskBashSyntaxChecks(command).replace(
      /\b(?:sys|process)\.(?:stdout|stderr)\.write\s*\(/g,
      "print(",
    );
    if (
      /\b(?:write_text|write_bytes|writeFile(?:Sync)?|appendFile(?:Sync)?|createWriteStream|write|writelines|truncate|rename(?:Sync)?|unlink(?:Sync)?|rmdir(?:Sync)?|mkdir(?:Sync)?|makedirs|remove|rmtree|copy(?:file|tree|2|File(?:Sync)?)?|chmod(?:Sync)?|chown(?:Sync)?|touch)\s*\(/i.test(
        code,
      ) ||
      /\b(?:open(?:Sync)?|fdopen)\s*\([\s\S]*?["'](?:[wax][bt+]*|r[bt]*\+[bt]*)["']/i.test(code) ||
      /\bO_(?:WRONLY|RDWR|CREAT|TRUNC|APPEND)\b/.test(code) ||
      /\b(?:os\.replace|Path\([^\n]*\)\.replace)\s*\(/.test(code) ||
      /\bopen\s+[^\n]*["'][>+]/.test(code) ||
      /\b(?:exec|eval|execSync|execFile(?:Sync)?|spawn(?:Sync)?|system|popen|subprocess|__import__|importlib|require|import)\s*\(/i.test(
        code,
      ) ||
      /\b(?:subprocess|child_process|shutil)\b/.test(code)
    ) {
      return "scripted file mutation or indirect execution";
    }
  }
  return undefined;
};

type Token = { value: string; operator: boolean };

// Only parse ordinary shell words and operators. Dynamic shell syntax stays gated.
// This is a workflow guard, not a sandbox for arbitrary programs or trusted aliases.
const tokenize = (command: string): Token[] | undefined => {
  const tokens: Token[] = [];
  let word = "";
  let started = false;
  let quote = "";
  const flush = () => {
    if (started) tokens.push({ value: word, operator: false });
    word = "";
    started = false;
  };
  for (let i = 0; i < command.length; i++) {
    const char = command[i];
    if (quote) {
      if (char === quote) quote = "";
      else if (char === "\\" && quote === '"') {
        const next = command[++i];
        if (next === undefined) return undefined;
        if (next !== "\n") word += /[$`"\\]/.test(next) ? next : "\\" + next;
      } else {
        if (quote === '"' && (char === "$" || char.charCodeAt(0) === 96)) return undefined;
        word += char;
      }
      continue;
    }
    if (char === "'" || char === '"') {
      quote = char;
      started = true;
    } else if (char === "\\") {
      const next = command[++i];
      if (next === undefined) return undefined;
      if (next !== "\n") {
        word += next;
        started = true;
      }
    } else if (char === "$" || char.charCodeAt(0) === 96) {
      return undefined;
    } else if (/\s/.test(char)) {
      flush();
      if (char === "\n") tokens.push({ value: ";", operator: true });
    } else if (";|&<>()".includes(char)) {
      // A file-descriptor prefix belongs to its redirection, not the argv.
      let prefix = "";
      if ((char === ">" || char === "<") && /^\d+$/.test(word)) {
        prefix = word;
        word = "";
        started = false;
      }
      flush();
      const match = command.slice(i).match(/^(?:[<>]&(?:\d+|-)|>>|<>|>\||&&|\|\||[;|&<>()])/);
      if (!match) return undefined;
      tokens.push({ value: prefix + match[0], operator: true });
      i += match[0].length - 1;
    } else if (char === "#" && !started) {
      while (i < command.length && command[i] !== "\n") i++;
      tokens.push({ value: ";", operator: true });
    } else {
      word += char;
      started = true;
    }
  }
  if (quote) return undefined;
  flush();
  return tokens;
};

// Resolve existing ancestors too, so a new file through a symlink is checked.
const physicalPath = (path: string): string => {
  try {
    return realpathSync(path);
  } catch (error) {
    if (!["ENOENT", "ENOTDIR"].includes((error as { code?: string }).code ?? "")) throw error;
    const parent = dirname(path);
    if (parent === path) throw error;
    if (lstatSync(path, { throwIfNoEntry: false })?.isSymbolicLink()) {
      return physicalPath(resolve(parent, readlinkSync(path)));
    }
    return resolve(physicalPath(parent), basename(path));
  }
};

const sensitivePath = /(^|\/)(\.git|\.jj|\.ssh|\.env(?:\.[^/]*)?|\.npmrc|\.yarnrc(?:\.yml)?|AGENTS\.md)(\/|$)|id_rsa|id_ed25519|known_hosts|authorized_keys|secret|token|credential|private[_-]?key|(^|\/)\.(zshrc|bashrc|bash_profile|profile|zprofile)$|(^|\/)\.pi\/agent(\/|$)/i;

const pathRisk = (path: unknown, cwd: string): string | undefined => {
  if (typeof path !== "string" || !path || /[$*?{}\[\]~\n]/.test(path) || path.split("/").includes("..")) return "unknown or dynamic mutation path";
  try {
    const root = physicalPath(resolve(cwd));
    const lexical = resolve(cwd, path);
    const target = physicalPath(lexical);
    const within = relative(root, target);
    if (!within || within === ".." || within.startsWith("../") || isAbsolute(within)) {
      return "workspace root or outside-workspace mutation";
    }
    if (sensitivePath.test(lexical) || sensitivePath.test(target) || /^\/(?:etc|private\/etc)\//.test(target)) {
      return "protected path";
    }
  } catch {
    return "unresolved mutation path";
  }
};

// Directory operations must not silently remove protected descendants. Do not
// follow symlinks here: pathRisk checks explicit targets, and deletion unlinks them.
const directoryRisk = (path: string): string | undefined => {
  const pending = [path];
  let checked = 0;
  while (pending.length) {
    const current = pending.pop()!;
    try {
      for (const entry of readdirSync(current, { withFileTypes: true })) {
        const child = resolve(current, entry.name);
        if (++checked > 1000) return "broad directory operation";
        if (sensitivePath.test(child)) return "directory contains protected paths";
        if (entry.isSymbolicLink()) return "directory contains symlinks requiring review";
        if (entry.isDirectory()) pending.push(child);
      }
    } catch (error) {
      if (!["ENOENT", "ENOTDIR"].includes((error as { code?: string }).code ?? "")) return "unreadable directory scope";
    }
  }
};

const gitInspection = new Set([
  "status", "diff", "log", "show", "blame", "ls-files", "ls-tree", "rev-parse",
  "rev-list", "describe", "shortlog", "name-rev", "merge-base", "cat-file",
  "check-ignore", "check-attr", "for-each-ref", "show-ref", "help", "version",
]);
const jjInspection = new Set([
  "status", "st", "diff", "log", "show", "evolog", "evolution-log",
  "interdiff", "root", "help", "version",
]);

const jjSubcommands = new Map<string, string[]>([
  ["bookmark", ["list", "l"]], ["b", ["list", "l"]], ["tag", ["list", "l"]],
  ["operation", ["log", "show", "diff"]], ["op", ["log", "show", "diff"]],
  ["file", ["list", "show", "annotate", "search"]],
  ["workspace", ["list", "root"]], ["config", ["list", "get", "path"]],
]);

// Unknown commands/aliases fail closed. Known subcommands are matched as words,
// including invocations with global options or absolute executable paths.
const vcsBlock = (tool: string, args: string[]): string | undefined => {
  if (args.some((arg) => /^(?:--config(?:-file|-env)?(?:=|$)|--exec-path(?:=|$)|--ignore-immutable$|-c(?:.+)?$)/.test(arg))) {
    return tool + " configuration or safety override";
  }
  const valued = tool === "git"
    ? ["-C", "--git-dir", "--work-tree", "--namespace"]
    : ["-R", "--repository", "--at-operation", "--at-op", "--color"];
  const standalone = tool === "git"
    ? ["--no-pager", "--paginate", "--literal-pathspecs", "--no-optional-locks"]
    : ["--no-pager", "--ignore-working-copy", "--quiet", "--debug"];
  const words: string[] = [];
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (valued.includes(arg)) {
      if (!args[++i]) return tool + " missing global option value";
      continue;
    }
    if (valued.some((option) => arg.startsWith(option + "=")) ||
        (tool === "git" && /^-C.+/.test(arg)) ||
        (tool === "jj" && /^-R.+/.test(arg))) continue;
    if (standalone.includes(arg)) continue;
    words.push(...args.slice(i));
    break;
  }
  const [sub, second, ...rest] = words;
  if (!sub || sub === "--help" || sub === "-h" || sub === "--version") return undefined;
  // Diff/inspection commands can launch external programs or write output.
  if (words.some((arg) => /^(?:--output(?:=|$)|--ext-diff$|--textconv$|--tool(?:=|$)|--editor(?:=|$)|--exec(?:=|$)|--upload-pack(?:=|$)|--receive-pack(?:=|$)|--filters$)/.test(arg))) {
    return tool + " external execution or file output";
  }
  let allowed = false;
  if (tool === "git") {
    allowed = gitInspection.has(sub);
    if (sub === "fetch") allowed = !words.some((arg) => /^--(?:prune|force)|^-[^-]*[pfu]|^\+|:/.test(arg));
    if (sub === "branch" || sub === "tag") {
      allowed = !second || ["--list", "-l"].includes(second) ||
        (sub === "branch" && ["-a", "-r", "--all", "--remotes", "--show-current", "-v", "-vv"].includes(second) &&
          rest.every((arg) => ["-a", "-r", "--all", "--remotes", "-v", "-vv"].includes(arg)));
      if (words.some((arg) => /^--(?:delete|force|move|copy|edit-description|set-upstream|unset-upstream)|^-[^-]*[dDmMcCf]/.test(arg))) allowed = false;
    }
    if (sub === "stash") allowed = ["list", "show"].includes(second);
    if (sub === "reflog") allowed = !second || second === "show";
    if (sub === "worktree") allowed = second === "list";
    if (sub === "remote") allowed = !second || ["-v", "--verbose", "show", "get-url"].includes(second);
    if (sub === "config") allowed = ["list", "get", "--list", "-l", "--get", "--get-all", "--get-regexp"].includes(second) &&
      !words.some((arg) => /^(?:--(?:add|set|unset|unset-all|replace-all|rename-section|remove-section|edit)(?:=|$)|-e)$/.test(arg));
  } else {
    allowed = jjInspection.has(sub) || (jjSubcommands.get(sub)?.includes(second) ?? false);
    if (sub === "git") allowed = ["fetch", "root"].includes(second) ||
      (second === "remote" && rest[0] === "list");
  }
  return allowed ? undefined : "Protected or unknown " + tool + " operation: " + words.join(" ");
};

const systemRules: Rule[] = [
  { name: "privileged or permission change", pattern: /(?:^|[\s;/])(sudo|chmod|chown)\b/ },
  { name: "disk tooling", pattern: /(?:^|[\s;/])(dd|mkfs|fdisk|parted)\b|\bdiskutil\s+erase/ },
  { name: "service mutation", pattern: /\blaunchctl\s+(bootstrap|bootout|kickstart|enable|disable|load|unload|remove|submit|asuser)\b/ },
  { name: "defaults mutation", pattern: /\bdefaults\s+(write|delete|rename|import)\b/ },
  { name: "package installation", pattern: /\b(npm|pnpm|yarn|pip3?|uv|poetry|pipx|conda|mamba|pi)\s+(install|add|sync|update|remove)\b|\bpython[\d.]*\s+-m\s+pip\s+install\b/ },
  { name: "generated temporary path", pattern: /\b(mktemp|tempfile)\b/ },
  { name: "build", pattern: /\b(npm|pnpm|yarn|vp)\s+(run\s+)?build\b|\b(make|just|go|cargo)\s+build\b|\bdocker\s+build/ },
];
const directoryCommands = new Set(["rm", "rmdir", "mv", "cp"]);
const fileCommands = new Set([...directoryCommands, "unlink", "mkdir", "touch", "ln", "tee", "truncate"]);
const readerCommands = new Set(["rg", "grep", "egrep", "fgrep", "echo", "printf", "cat", "head", "tail", "ls"]);
const shellCommands = new Set(["bash", "sh", "zsh", "ksh", "dash"]);

const shellRisk = (command: string, cwd: string): { blocked?: string; ask: string[] } => {
  const ask = systemRules.filter((rule) => rule.pattern.test(command)).map((rule) => rule.name);
  const scriptRisk = getScriptRisk(command);
  if (scriptRisk) ask.push(scriptRisk);
  const tokens = tokenize(command);
  if (!tokens) {
    if (/\b(?:git|jj)\b/.test(command)) return { blocked: "Unclear Git/jj shell invocation", ask };
    return { ask: [...ask, "unsupported or dynamic shell syntax"] };
  }
  const changesDirectory = tokens.some((token) => !token.operator && ["cd", "pushd", "popd"].includes(token.value));
  const groups: Token[][] = [[]];
  for (const token of tokens) {
    if (token.operator && [";", "|", "||", "&&", "&", "(", ")"].includes(token.value)) groups.push([]);
    else groups[groups.length - 1].push(token);
  }
  for (const group of groups) {
    const words: string[] = [];
    for (let i = 0; i < group.length; i++) {
      const token = group[i];
      if (!token.operator) {
        words.push(token.value);
        continue;
      }
      if (/^\d*[<>]&(?:\d+|-)$/.test(token.value)) continue;
      const target = group[++i];
      if (!target || target.operator) {
        ask.push("unknown redirection");
        continue;
      }
      if (token.value.includes(">") && target.value !== "/dev/null") {
        const risk = changesDirectory ? "mutation after directory change" : pathRisk(target.value, cwd);
        if (risk) ask.push(risk);
      }
    }
    const name = basename(words[0] ?? "");
    const literalArguments = readerCommands.has(name);
    if (name === "rg" && words.some((word) => /^--(?:pre|hostname-bin)(?:=|$)/.test(word))) {
      ask.push("search command runs an external program");
    }
    // Inspect wrapped commands, but treat ordinary reader arguments as data.
    for (let i = 0; i < words.length && !literalArguments; i++) {
      const name = basename(words[i]);
      if (name === "git" || name === "jj") {
        const blocked = vcsBlock(name, words.slice(i + 1));
        if (blocked) return { blocked, ask };
        break;
      }
      if (shellCommands.has(name) && words[i + 1] !== "-n") {
        const flag = words.findIndex((word, index) => index > i && /^-[^-]*c/.test(word));
        if (flag >= 0 && words[flag + 1]) {
          const nested = shellRisk(words[flag + 1], cwd);
          if (nested.blocked) return nested;
        }
        ask.push("shell execution requiring review");
      }
      if (["eval", "source", "."].includes(name) && i === 0) {
        if (name === "eval") {
          const nested = shellRisk(words.slice(1).join(" "), cwd);
          if (nested.blocked) return nested;
        }
        ask.push("indirect shell execution");
      }
    }
    if (fileCommands.has(name)) {
      const paths = words.slice(1).filter((word) => !word.startsWith("-"));
      // Only familiar switches are automatic; attached path operands and options
      // that follow symlinks need review rather than being mistaken for flags.
      if (words.slice(1).some((word) => word.startsWith("-") && word !== "--" &&
          !/^-[rfpivRans]+$/.test(word) &&
          !["--recursive", "--force", "--parents", "--verbose"].includes(word))) ask.push("unreviewed file operation option");
      if (!paths.length) ask.push("unknown file operation targets");
      for (const path of paths) {
        const risk = changesDirectory ? "mutation after directory change" : pathRisk(path, cwd);
        if (risk) ask.push(risk);
        else if (directoryCommands.has(name)) {
          const treeRisk = directoryRisk(resolve(cwd, path));
          if (treeRisk) ask.push(treeRisk);
        }
      }
    } else if (!literalArguments && (/\b(?:rm|unlink|rmdir|mv|cp|mkdir|touch|ln|tee|truncate|sed\s+-i|perl\s+-pi|ruby\s+-pi)\b/.test(words.join(" ")) ||
        (name === "find" && words.some((word) => ["-delete", "-exec", "-execdir", "-ok", "-okdir"].includes(word))))) {
      ask.push("indirect or in-place file mutation");
    }
  }
  return { ask };
};

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    const cwd = ctx.cwd ?? process.cwd();
    const reasons: string[] = [];
    const details: string[] = [];
    const checks = collectToolCalls(event);
    const shellChecks = checks.filter(({ name }) => name === "bash" || name === "hypa_shell");
    for (const check of shellChecks) {
      const command = getCommand(check.input);
      const risk = shellRisk(command, cwd);
      if (risk.blocked) return { block: true, reason: risk.blocked + ". Run this yourself if needed." };
      reasons.push(...risk.ask);
      details.push(command);
    }

    const mutations = checks.filter(({ name, input }) =>
      name === "edit" || name === "write" ||
      (["ast_grep_replace", "lsp_navigation"].includes(name) && input.apply === true),
    );
    for (const check of mutations) {
      const input = check.input;
      const paths = [input.path, input.newFilePath];
      if (Array.isArray(input.paths)) paths.push(...input.paths);
      // ast-grep uses paths; no path or broad glob means the scope needs approval.
      const targets = paths.filter((path) => path !== undefined);
      if (!targets.length) reasons.push("mutation tool has no explicit paths");
      for (const path of targets) {
        const risk = pathRisk(path, cwd);
        if (risk) reasons.push(risk);
        if (check.name === "ast_grep_replace" && typeof path === "string") {
          try {
            if (statSync(resolve(cwd, path)).isDirectory()) reasons.push("bulk replacement needs explicit file paths");
          } catch {
            reasons.push("unresolved bulk replacement path");
          }
        }
      }
      if (check.name === "lsp_navigation") {
        reasons.push("LSP edit may affect files beyond the supplied path");
      }
      details.push(check.toolName + ": " + JSON.stringify(targets));
    }

    if (!reasons.length) return undefined;
    const reason = [...new Set(reasons)].join(", ");
    if (!ctx.hasUI) return { block: true, reason: "Approval required (no UI): " + reason };
    if (!(await ctx.ui.confirm("Allow protected or unclear operation?", reason + "\n\n" + details.join("\n\n")))) {
      return { block: true, reason: "Blocked by user: " + reason };
    }
    return undefined;
  });
}
