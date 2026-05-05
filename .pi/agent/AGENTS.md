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

## Execution mode: plan vs do

- Detect user intent from phrasing before acting.
- If the user asks exploratory questions (e.g., "how would this work", "how would you", "what’s the approach", "can you outline"), respond with a concise plan/pitch first and do not execute changes yet.
- If the user gives direct implementation commands (e.g., "do X", "implement Y", "change this", "fix it"), execute immediately without pitching first.
- No implicit mutation: for informational/planning requests, read-only tools may be used to gather context, but do not perform mutating actions (file edits/writes or state-changing commands) unless the user explicitly asks to execute.
- Continue to follow safety/approval gates: if the request is ambiguous, risky, destructive, or conflicts with higher-priority instructions, pause and confirm before proceeding.

## Tooling preferences

- Prefer `bun` over `npm` for JavaScript/TypeScript workflows and command suggestions.
- Only suggest `npm` when required for compatibility or when a tool explicitly requires npm semantics.
- Prefer `uv` over `pip` for Python package installation workflows and command suggestions.
- Only suggest `pip` when required for compatibility or when a tool explicitly requires pip semantics.
- For pi package management, use `pi install` / `pi update` / `pi remove` commands as the primary interface.

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
