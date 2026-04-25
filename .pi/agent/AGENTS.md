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
- If requirements are ambiguous, ask before making broad edits.

## Tooling preferences
- Prefer `bun` over `npm` for JavaScript/TypeScript workflows and command suggestions.
- Only suggest `npm` when required for compatibility or when a tool explicitly requires npm semantics.
- For pi package management, use `pi install` / `pi update` / `pi remove` commands as the primary interface.

## Editing configs
- When asked to edit configs, look in ~/dotfiles first.
