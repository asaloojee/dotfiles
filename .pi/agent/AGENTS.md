# Global agent directives

## Workflow and communication

- Keep diffs small, scoped, and readable; avoid unrelated refactors and formatting churn. Explain non-obvious changes.
- Treat exploratory questions and recommendations as advice-only. Implement direct requests; answer any accompanying questions before editing.
- Ask before ambiguous, broad, risky, destructive, or conflicting work. Do not expand scope without approval.
- Do not run builds or implement responsive styling unless explicitly requested.
- Briefly summarize **why**, **what** (files and behavior), and **impact** (risks, tradeoffs, verification).
- Use plain language following ISO 24495-1:2023 at all times.

## Safe changes

- Read relevant files with the built-in read tool before editing.
- Never bypass the safety gate. Route all mutations—including shell writes, migrations, deletes, and installs—through approved tools and permission checks.
- Prefer targeted edits; use scripts or full rewrites only when appropriate.
- Prefer dry runs, previews, or diffs before mutations when practical.
- Never run commands requiring `sudo` or a password. Provide exact privileged commands as clearly labeled user-run steps, including rebuilds, rollbacks, garbage collection, and generation deletion.

## Tooling

- For JavaScript/TypeScript, prefer global `vp` commands and `pnpm`; prefer `vp` over local `pnpm exec` equivalents. Use `yarn` only in `~/dev/pre-script/` projects and `npm` only when required.
- Prefer `uv`; use `pip` only when required.
- Manage pi packages with `pi install`, `pi update`, and `pi remove`.

## Formatting

- Follow `~/dotfiles/.config/nvim/lua/plugins/conform.lua`; prefer project formatter commands over raw binaries.
- In Vite Plus projects, use `vp fmt`/oxfmt for supported web files; otherwise use Conform's formatter or the ecosystem standard (e.g., `rustfmt`). Use Svelte LSP formatting for Svelte.
- Use Prettier only when configured by the project; use pi-specific source formatters only when explicitly requested.
- Run formatters only when requested or clearly required. Use canonical formatting; warn before substantial formatting churn.

## Configuration

- Treat `~/dotfiles` as the source of truth. Inspect it before configuration changes, even in other repositories; prefer global changes there unless repository-local scope is requested.
- Do not edit generated or deployed files in `$HOME` unless explicitly requested.
- System configuration: `~/dotfiles/nix` (flake-based nix-darwin and home-manager). Stow-managed files: `~/dotfiles`, linked into `$HOME`.

## Hunk reviews

- Use `hunk session *` to inspect live reviews. Never launch interactive `hunk diff`/`hunk show` in the agent shell; ask the user to open Hunk in their terminal if needed.
- Find sessions with `hunk session list --json`; confirm the repo/source with `hunk session get --repo . --json`. Use an exact session ID instead of `--repo .` when multiple sessions match; ask if unclear.
- Read the loaded changeset with `hunk session review --repo . --json`: add `--include-notes` for notes and `--include-patch` only when raw diff text is needed. Do not assume it shows working-tree changes.
- Read comments with `hunk session comment list --repo . --type all --json` (the default omits some types). Use `--type user` for user-only notes or `--file <path>` to filter.
- Check diff/source context before assessing comments. Report location, author/type, and requested action; distinguish issues from questions/suggestions and verify fixes before claiming resolution.
- Look/view/review requests are read-only: no code or comment changes, reloads, or viewport movement unless requested. For walkthroughs, use `session context` and `session navigate`; `--comment <commentId>` jumps to a note.
- When asked to leave feedback, use `session comment add` for one note or `comment apply --stdin` for batches. Root notes need a file and exactly one old/new line; replies use `--reply-to <note-id>`. Use `--focus` only to steer the view; otherwise mention `a` if agent notes are hidden.
- If Hunk is open but inaccessible, report possible localhost/sandbox restrictions. Never restart its daemon without approval.
- Reference: [official Hunk review skill](https://github.com/modem-dev/hunk/blob/main/packages/hunk/skills/hunk-review/SKILL.md). Check installed `--help` for version differences; never invent flags.
