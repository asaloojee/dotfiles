/**
 * Safety Gate Extension
 *
 * Adds confirmations for dangerous shell commands and sensitive file edits.
 * - Confirms before bash/hypa_shell commands like rm, mv, launchctl mutations, sudo, chmod/chown, dd, mkfs, install/build commands, etc.
 * - Confirms before git commands that can change the current working tree (revert/reset/checkout/restore/etc.).
 * - Catches direct, namespaced, and nested multi_tool_use tool calls.
 * - Confirms before edit/write and apply=true mutation tools.
 * - In non-interactive mode, blocks these actions by default.
 */

type ToolCallEvent = { toolName: string; input: Record<string, unknown> };
type ToolCallContext = {
	hasUI: boolean;
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
type ToolCheck = {
	toolName: string;
	input: Record<string, unknown>;
	source: string;
};

type NestedToolUse = {
	recipient_name?: unknown;
	name?: unknown;
	parameters?: unknown;
	arguments?: unknown;
};

const getToolBaseName = (toolName: string) =>
	toolName.split(".").pop() ?? toolName;

const isRecord = (value: unknown): value is Record<string, unknown> =>
	typeof value === "object" && value !== null && !Array.isArray(value);

const getToolInput = (value: unknown): Record<string, unknown> =>
	isRecord(value) ? value : {};

const isToolNamed = (toolName: string, names: string[]) => {
	const baseName = getToolBaseName(toolName);
	return names.includes(toolName) || names.includes(baseName);
};

const getCommand = (input: Record<string, unknown>) => {
	for (const key of ["command", "cmd", "script"]) {
		const value = input[key];
		if (typeof value === "string") return value;
	}
	return "";
};

const collectToolChecks = (
	event: ToolCallEvent,
	matchesTool: (toolName: string) => boolean,
): ToolCheck[] => {
	const checks: ToolCheck[] = [];
	if (matchesTool(event.toolName)) {
		checks.push({
			toolName: event.toolName,
			input: event.input,
			source: "direct",
		});
	}

	const nestedTools = event.input.tool_uses;
	if (!Array.isArray(nestedTools)) return checks;

	for (const nestedTool of nestedTools) {
		if (!isRecord(nestedTool)) continue;
		const toolUse = nestedTool as NestedToolUse;
		const toolName = String(toolUse.recipient_name ?? toolUse.name ?? "");
		if (!toolName || !matchesTool(toolName)) continue;

		checks.push({
			toolName,
			input: getToolInput(toolUse.parameters ?? toolUse.arguments),
			source: `${event.toolName} nested`,
		});
	}

	return checks;
};

export default function (pi: ExtensionAPI) {
	const dangerousCommandRules: Rule[] = [
		{ name: "remove files (rm)", pattern: /(^|\s)rm\s+/i },
		{
			name: "remove files (unlink/rmdir)",
			pattern: /(^|\s)(unlink|rmdir)\s+/i,
		},
		{ name: "move/rename files (mv)", pattern: /(^|\s)mv\s+/i },
		{ name: "copy files (cp)", pattern: /(^|\s)cp\s+/i },
		{ name: "create/link files", pattern: /(^|\s)(touch|mkdir|ln)\s+/i },
		{
			name: "shell redirection write",
			pattern: /(^|\s)(>|>>)|\s(>|>>)\s*[^&]/i,
		},
		{ name: "write through tee", pattern: /(^|\s)tee\s+/i },
		{ name: "truncate files", pattern: /(^|\s)truncate\s+/i },
		{ name: "sudo", pattern: /(^|\s)sudo\s+/i },
		{ name: "chmod", pattern: /(^|\s)chmod\s+/i },
		{ name: "chown", pattern: /(^|\s)chown\s+/i },
		{ name: "dd (raw disk write)", pattern: /(^|\s)dd\s+/i },
		{
			name: "disk/filesystem tooling",
			pattern: /(^|\s)(mkfs|fdisk|parted|diskutil\s+eraseDisk)\b/i,
		},
		{
			name: "launchd service mutation",
			pattern:
				/\blaunchctl\s+(bootstrap|bootout|kickstart|enable|disable|load|unload|remove|submit|asuser)\b/i,
		},
		{
			name: "macOS defaults mutation",
			pattern: /\bdefaults\s+(write|delete|rename|import)\b/i,
		},
		{
			name: "recursive delete flags",
			pattern: /\brm\b[^\n]*\s(-r|-rf|-fr|--recursive)\b/i,
		},
		{
			name: "force overwrite flags",
			pattern: /\b(mv|cp)\b[^\n]*\s(-f|--force)\b/i,
		},
		{
			name: "in-place shell edit",
			pattern: /\b(sed\s+-i|perl\s+-pi|ruby\s+-pi)\b/i,
		},
		{
			name: "scripted file mutation command",
			pattern: /(^|\s)(?:[^\s]+\/)?(python\d*|node|ruby|perl|php|bun|deno)\b/i,
		},
		{
			name: "temp-file replacement workflow",
			pattern:
				/\b(mktemp|tempfile)\b|\b(mv|cp)\b[^\n]*(\/tmp\/|\.tmp\b|\.temp\b)|(?:\/tmp\/|\.tmp\b|\.temp\b)[^\n]*\b(mv|cp)\b/i,
		},
		{
			name: "package manager install commands",
			pattern:
				/\b(npm|pnpm|yarn|pip|pip3|uv|poetry|pipx|conda|mamba)\s+(install|add|sync)\b/i,
		},
		{
			name: "python module install",
			pattern: /\bpython\d*\s+-m\s+pip\s+install\b/i,
		},
		{
			name: "package manager build scripts",
			pattern: /\b(npm|pnpm|yarn)\s+(run\s+)?build\b/i,
		},
		{ name: "make/just build", pattern: /\b(make|just)\s+build\b/i },
		{ name: "docker build", pattern: /\bdocker\s+buildx?\b/i },
		{ name: "language/toolchain build", pattern: /\b(go|cargo)\s+build\b/i },
	];

	const gitCodeChangeRules: Rule[] = [
		{ name: "git restore", pattern: /\bgit\s+restore\b/i },
		{ name: "git reset", pattern: /\bgit\s+reset\b/i },
		{ name: "git revert", pattern: /\bgit\s+revert\b/i },
		{ name: "git clean", pattern: /\bgit\s+clean\b/i },
		{ name: "git merge", pattern: /\bgit\s+merge\b/i },
		{ name: "git rebase", pattern: /\bgit\s+rebase\b/i },
		{ name: "git cherry-pick", pattern: /\bgit\s+cherry-pick\b/i },
		{ name: "git pull", pattern: /\bgit\s+pull\b/i },
		{ name: "git apply", pattern: /\bgit\s+apply\b/i },
		{ name: "git am", pattern: /\bgit\s+am\b/i },
		{
			name: "git stash apply/pop/push/branch",
			pattern: /\bgit\s+stash\s+(apply|pop|push|branch)\b/i,
		},
	];

	const sensitivePathPatterns: Rule[] = [
		{ name: "dotenv secrets", pattern: /(^|\/)\.env($|\.|\/)/i },
		{ name: "git internals", pattern: /(^|\/)\.git(\/|$)/i },
		{
			name: "SSH config/keys",
			pattern:
				/(^|\/)\.ssh(\/|$)|id_rsa|id_ed25519|known_hosts|authorized_keys/i,
		},
		{
			name: "npm/yarn auth",
			pattern: /(^|\/)\.npmrc$|(^|\/)\.yarnrc(\.yml)?$/i,
		},
		{ name: "system config", pattern: /^\/etc\//i },
		{
			name: "shell profile",
			pattern: /(^|\/)\.(zshrc|bashrc|bash_profile|profile|zprofile)$/i,
		},
		{
			name: "credentials",
			pattern: /secret|token|credential|private[_-]?key/i,
		},
	];

	pi.on("tool_call", async (event, ctx) => {
		const shellChecks = collectToolChecks(event, (toolName) =>
			isToolNamed(toolName, ["bash", "hypa_shell"]),
		);
		const riskyShellChecks = shellChecks.flatMap((check) => {
			const command = getCommand(check.input);
			const dangerousMatches = dangerousCommandRules.filter((r) =>
				r.pattern.test(command),
			);
			const gitChangeMatches = gitCodeChangeRules.filter((r) =>
				r.pattern.test(command),
			);
			const matches = [...dangerousMatches, ...gitChangeMatches];
			return matches.length > 0 ? [{ ...check, command, matches }] : [];
		});

		if (riskyShellChecks.length > 0) {
			const matchedRules = riskyShellChecks
				.flatMap((check) => check.matches.map((match) => match.name))
				.join(", ");

			if (!ctx.hasUI) {
				return {
					block: true,
					reason: `Blocked write/risky command requiring confirmation (no UI): ${matchedRules}`,
				};
			}

			const commandSummary = riskyShellChecks
				.map(
					(check) =>
						`Tool: ${check.toolName} (${check.source})\nCommand:\n\n${check.command}\n\nMatched rules: ${check.matches.map((match) => match.name).join(", ")}`,
				)
				.join("\n\n---\n\n");
			const confirmed = await ctx.ui.confirm(
				"Allow write/risky command requiring confirmation?",
				commandSummary,
			);
			if (!confirmed) {
				return { block: true, reason: "Blocked by user" };
			}
			return undefined;
		}

		const fileMutationChecks = collectToolChecks(event, (toolName) =>
			isToolNamed(toolName, ["write", "edit"]),
		);
		if (fileMutationChecks.length > 0) {
			const mutationSummary = fileMutationChecks
				.map((check) => {
					const path = String(check.input.path ?? "");
					const matches = sensitivePathPatterns.filter((r) =>
						r.pattern.test(path),
					);
					const matchedRules =
						matches.length > 0
							? matches.map((match) => match.name).join(", ")
							: "none";
					return `Tool: ${check.toolName} (${check.source})\nPath: ${path}\nMatched sensitive rules: ${matchedRules}`;
				})
				.join("\n\n---\n\n");

			if (!ctx.hasUI) {
				return {
					block: true,
					reason: `Blocked file mutation tool (no UI): ${fileMutationChecks.map((check) => check.toolName).join(", ")}`,
				};
			}

			const confirmed = await ctx.ui.confirm(
				"Allow file mutation operation?",
				mutationSummary,
			);
			if (!confirmed) {
				return { block: true, reason: "Blocked file mutation by user" };
			}
		}

		const applyMutationChecks = collectToolChecks(event, (toolName) =>
			isToolNamed(toolName, ["ast_grep_replace", "lsp_navigation"]),
		).filter((check) => check.input.apply === true);
		if (applyMutationChecks.length > 0) {
			const mutationSummary = applyMutationChecks
				.map(
					(check) =>
						`Tool: ${check.toolName} (${check.source})\nInput:\n\n${JSON.stringify(check.input, null, 2)}`,
				)
				.join("\n\n---\n\n");

			if (!ctx.hasUI) {
				return {
					block: true,
					reason: `Blocked apply=true mutation tool (no UI): ${applyMutationChecks.map((check) => check.toolName).join(", ")}`,
				};
			}

			const confirmed = await ctx.ui.confirm(
				"Allow apply=true mutation operation?",
				mutationSummary,
			);
			if (!confirmed) {
				return { block: true, reason: "Blocked apply=true mutation by user" };
			}
		}

		return undefined;
	});
}
