# Global agent directives

## Review-first workflow

- Optimize all code changes for human review and understanding.
- Keep diffs small, scoped, and easy to read.
- Avoid unrelated refactors/format churn unless explicitly requested.
- Prefer incremental edits over large rewrites when possible.

## Explain every change concisely

When proposing or completing changes, include a brief summary with:

1. **Why**: the reason for the change.
2. **What**: files touched and key behavior/code changes.
3. **Impact**: risks, tradeoffs, and how to verify.

## Approval mindset

- Assume the user will review/approve only after understanding the diff.
- If a change is non-obvious, call it out explicitly before or after editing.
- If requirements, specs, or direction are ambiguous, ask concise clarifying questions before making broad edits.

## Execution mode: advice vs edits

- Detect user intent from phrasing before acting.
- If the user asks exploratory questions or requests recommendations (e.g., "how would this work", "how would you", "what’s the approach", "can you outline", "what do you recommend"), respond with explanation, advice, or a concise plan only. Do not initiate file edits, writes, or other mutating commands.
- If the user gives a direct edit or implementation request (e.g., "do X", "implement Y", "change this", "fix it", "make the edit"), initiate the requested edit/write through the approved tool path so the safety gate extension can intercept it for approval.
- Under no circumstances bypass the safety gate extension for mutations. Do not mutate files or project state through shell scripts, shell redirection, install/remove commands, migrations, deletes, or other state-changing commands unless that action is explicitly expected to be caught by the safety gate. Project-standard formatter CLI commands are an allowed exception when they are explicitly requested or clearly part of the requested implementation workflow.
- Permanently banned mutation paths: `python`/`node`/`ruby`/similar scripts that write files, shell redirection (`>`/`>>`), in-place shell edits (`sed -i`, `perl -pi`, etc.), `mv`/`cp` over source files, temp-file replacement workflows, and full-file rewrites for small edits unless explicitly approved.
- For files owned by the configured formatter (for example oxfmt via `vp fmt`/Neovim Conform), do not introduce or preserve non-canonical formatting such as tab indentation to minimize a diff. If formatting churn is likely because the committed file is not formatter-canonical, call that out before editing.
- No implicit mutation: for informational/planning requests, read-only tools may be used to gather context, but do not perform mutating actions unless the user explicitly asks for an edit/implementation.
- Continue to follow safety/approval gates: if the request is ambiguous, risky, destructive, or conflicts with higher-priority instructions, pause and confirm before proceeding.

## Tooling preferences

- Prefer `pnpm` for JavaScript/TypeScript workflows and command suggestions.
- Only suggest `npm` when required for compatibility or when a tool explicitly requires npm semantics.
- Prefer `uv` over `pip` for Python package installation workflows and command suggestions.
- Only suggest `pip` when required for compatibility or when a tool explicitly requires pip semantics.
- For pi package management, use `pi install` / `pi update` / `pi remove` commands as the primary interface.

## Formatting parity with Neovim

- When editing code, match my Neovim Conform formatter setup from `~/dotfiles/.config/nvim/lua/plugins/conform.lua`.
- Do not use Prettier unless the project explicitly configures Prettier.
- Where applicable, prefer the project's formatter command over a raw formatter binary; for Vite Plus projects, use `vp fmt`.
- For JS, TS, CSS, HTML, JSON, YAML, Markdown, and similar web files, oxfmt via `vp fmt` / Neovim Conform is the canonical formatter when `vite-plus` / `vp` is available; otherwise use the formatter selected by Conform.
- Formatter write commands are allowed when they use the project-standard formatter that is already available in the repo/toolchain. Prefer `vp fmt` / `oxfmt` for web files in Vite Plus projects, and use standard ecosystem formatters such as `rustfmt` for Rust projects when appropriate.
- Do not use pi-specific formatting tools for source files unless explicitly requested; they may use different whitespace standards than Neovim/Conform and can create noisy diffs.
- For Svelte files, remember that Neovim uses Svelte LSP formatting rather than `oxfmt`.

## Editing configs

- Treat `~/dotfiles` as the primary source of truth for system/user configuration.
- For config-change requests, inspect `~/dotfiles` first to determine whether the change should be global or local.
- Default bias: prefer global changes in `~/dotfiles` unless the user explicitly requests repository-local scope.
- If asked from another repository to make a global config change, check `~/dotfiles` first and proceed based on context and user intent.
- Avoid editing generated or deployed targets in `$HOME` directly (e.g., files materialized by nix-darwin/home-manager/stow) unless explicitly requested.
- Scope lock: do not expand to unrelated files or directories without user approval.

## Dotfiles setup awareness (nix-darwin + home-manager + stow)

- Primary system config lives under `~/dotfiles/nix` (flake-based nix-darwin + home-manager modules).
- Stow-managed config files live directly in `~/dotfiles` (for example, `~/dotfiles/.config/...`) and are linked into `$HOME`.

## Apply/verify workflow for global changes

- Prefer these commands when relevant:
  - `just stow` for stow-managed symlinks.
  - `just diff` to inspect closure differences before/after.
- Prefer dry-run/preview/diff-style validation before mutating changes when practical.
- Never run commands that require `sudo` or may trigger a password prompt.
- For any privileged step (including rebuilds, rollback, gc, deleting generations, or nix/darwin commands requiring sudo), hand off to the user with the exact command(s) to run.
- The agent may run non-privileged verification commands, but must clearly label any user-run privileged follow-up.
