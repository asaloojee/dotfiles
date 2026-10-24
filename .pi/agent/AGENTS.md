# Global agent directives

## Workflow

- Keep changes as simple, small, and scoped as possible without sacrificing robustness or security. Avoid unrelated refactors and formatting churn.
- Questions, possibilities, recommendations, and review requests are advice-only. Explain first; edit only when instructed. An implementation request authorizes routine, task-scoped edits, moves, and deletions without per-edit approval.
- Ask before ambiguous, broad, high-risk, or conflicting work, or expanding scope. Never use another tool to evade a restriction.
- Use plain language. Explain non-obvious choices and tradeoffs even when no approval prompt is needed.
- Do not run builds or implement responsive styling unless explicitly requested.

## Changes and review

- Read relevant files before editing. Check the initial working-tree state; preserve and distinguish pre-existing work.
- Prefer targeted edits and practical previews. Use smaller checkpoints for large or high-risk tasks.
- Run relevant permitted checks. Report what ran, what passed, and what remains untested; do not claim manual behavior checks you did not perform.
- Hand off the result, changed files and reasons, design tradeoffs, verification, and review focus. Note scope deviations or overlap with existing work. Keep small-task summaries brief.
- The user checks behavior, reviews the final diff in Hunk, requests fixes, and owns staging and Git/jj history or publication changes. Provide user-run commands when needed; normal jj working-copy snapshots are allowed. Offer walkthroughs or commit messages when asked.
- Never run commands requiring `sudo` or a password; provide clearly labeled user-run steps instead.

## Tooling and formatting

- For JavaScript/TypeScript, prefer global `vp` and `pnpm`; prefer `vp` over local `pnpm exec` equivalents. Use `yarn` only in `~/dev/pre-script/` projects and `npm` only when required.
- Prefer `uv`; use `pip` only when required. Manage pi packages with `pi install`, `pi update`, and `pi remove`.
- Follow `~/dotfiles/.config/nvim/lua/plugins/conform.lua` and prefer project formatter commands. In Vite Plus projects, use `vp fmt`/oxfmt for supported web files; use Svelte LSP formatting for Svelte. Otherwise use the configured or ecosystem-standard formatter.
- Use Prettier only when configured; use pi-specific source formatters only when explicitly requested. Run formatters only when requested or clearly required, and warn before substantial churn.

## Configuration

- Treat `~/dotfiles` as the source of truth. Inspect it before configuration changes; prefer global changes there unless repository-local scope is requested.
- Do not edit generated or deployed files in `$HOME` unless explicitly requested.
- System configuration: `~/dotfiles/nix` (flake-based nix-darwin/home-manager). Stow-managed files live in `~/dotfiles` and link into `$HOME`.

## Hunk reviews

- Use `hunk session *` for live reviews; never launch interactive `hunk diff`/`hunk show` in the agent shell. Ask the user to open Hunk if needed. Check installed `--help`; never invent flags.
- Find sessions with `hunk session list --json`; confirm the repo/source with `hunk session get --repo . --json`. Use an exact session ID if multiple sessions match; ask if unclear.
- Read the loaded changeset with `hunk session review --repo . --json`; add `--include-notes` for notes and `--include-patch` only when needed. Confirm it represents the intended final state; do not assume it shows current working-tree changes.
- Read comments with `hunk session comment list --repo . --type all --json`; use `--type user` or `--file <path>` to filter. Check source context; report location, author/type, and requested action. Distinguish questions from fixes and verify fixes before claiming resolution.
- Review requests are read-only: no edits, comments, reloads, or viewport movement unless requested. Requested walkthroughs use `session context`/`session navigate`; `--comment <commentId>` jumps to a note.
- When asked to leave feedback, use `session comment add` or `comment apply --stdin`. Root notes need a file and exactly one old/new line; replies use `--reply-to <note-id>`. Use `--focus` only to steer the view; otherwise mention `a` if agent notes are hidden.
- If Hunk is inaccessible, report possible localhost/sandbox restrictions. Never restart its daemon without approval.
- Reference: [official Hunk review skill](https://github.com/modem-dev/hunk/blob/main/packages/hunk/skills/hunk-review/SKILL.md).
