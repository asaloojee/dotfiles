/**
 * Safety Gate Extension
 *
 * Adds confirmations for dangerous shell commands and sensitive file edits.
 * - Confirms before bash commands like rm, mv, sudo, chmod/chown, dd, mkfs, build commands, etc.
 * - Confirms before git commands that can change the current working tree (revert/reset/checkout/restore/etc.).
 * - Allows read-only git inspection commands (diff/log/show/status) without prompting.
 * - Confirms before edit/write on sensitive paths (.env, .git, .ssh, keys, etc.)
 * - In non-interactive mode, blocks these actions by default.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

type Rule = { name: string; pattern: RegExp };

export default function (pi: ExtensionAPI) {
	const dangerousCommandRules: Rule[] = [
		{ name: "remove files (rm)", pattern: /(^|\s)rm\s+/i },
		{ name: "move/rename files (mv)", pattern: /(^|\s)mv\s+/i },
		{ name: "sudo", pattern: /(^|\s)sudo\s+/i },
		{ name: "chmod", pattern: /(^|\s)chmod\s+/i },
		{ name: "chown", pattern: /(^|\s)chown\s+/i },
		{ name: "dd (raw disk write)", pattern: /(^|\s)dd\s+/i },
		{
			name: "disk/filesystem tooling",
			pattern: /(^|\s)(mkfs|fdisk|parted|diskutil\s+eraseDisk)\b/i,
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
			name: "package manager build scripts",
			pattern: /\b(npm|pnpm|yarn|bun)\s+(run\s+)?build\b/i,
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
		if (event.toolName === "bash") {
			const command = String(event.input.command ?? "");
			const dangerousMatches = dangerousCommandRules.filter((r) =>
				r.pattern.test(command),
			);
			const gitChangeMatches = gitCodeChangeRules.filter((r) =>
				r.pattern.test(command),
			);
			const matches = [...dangerousMatches, ...gitChangeMatches];
			if (matches.length === 0) return undefined;

			if (!ctx.hasUI) {
				return {
					block: true,
					reason: `Blocked command requiring confirmation (no UI): ${matches.map((m) => m.name).join(", ")}`,
				};
			}

			const confirmed = await ctx.ui.confirm(
				"Allow command requiring confirmation?",
				`Command:\n\n${command}\n\nMatched rules: ${matches.map((m) => m.name).join(", ")}`,
			);
			if (!confirmed) {
				return { block: true, reason: "Blocked by user" };
			}
			return undefined;
		}

		if (event.toolName === "write" || event.toolName === "edit") {
			const path = String(event.input.path ?? "");
			const matches = sensitivePathPatterns.filter((r) => r.pattern.test(path));
			const matchedRules =
				matches.length > 0 ? matches.map((m) => m.name).join(", ") : "none";

			if (!ctx.hasUI) {
				return {
					block: true,
					reason: `Blocked ${event.toolName} (no UI): ${path}`,
				};
			}

			const confirmed = await ctx.ui.confirm(
				`Allow ${event.toolName} operation?`,
				`Path: ${path}\n\nMatched sensitive rules: ${matchedRules}`,
			);
			if (!confirmed) {
				return { block: true, reason: `Blocked ${event.toolName}: ${path}` };
			}
		}

		return undefined;
	});
}
