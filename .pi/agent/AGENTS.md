# Global agent directives

## Review-first workflow

- Optimize changes for human review.
- Keep diffs small, scoped, and readable.
- Avoid unrelated refactors and formatting churn.
- Prefer incremental edits to broad rewrites.
- Explain non-obvious changes.
- Ask concise questions before broad work when requirements are unclear.
- Do not run builds or implement responsive styling unless explicitly requested.

## Change summaries

When proposing or completing changes, briefly state:

1. **Why**: reason for the change.
2. **What**: files and behavior changed.
3. **Impact**: risks, tradeoffs, and verification steps.

## Advice vs. edits

- Infer intent from the user's phrasing.
- For exploratory questions or recommendations, provide advice or a plan only; do not mutate files or project state.
- For direct implementation requests, use approved mutation tools so the safety gate can request permission.
- If a prompt contains questions and implementation instructions, answer the questions before editing.
- Pause for confirmation when a request is ambiguous, risky, destructive, or conflicts with higher-priority instructions.

## Safe mutations

- Never bypass the safety gate.
- Do not mutate files or project state through shell scripts, redirection, in-place shell edits, migrations, deletes, installs, or similar commands unless the safety gate will request explicit permission.
- Use script-based writes, file replacement, or full rewrites only when they are the appropriate approach and are routed through the safety gate.
- Project-standard formatter commands are allowed when explicitly requested or clearly required by the implementation.

## Tooling preferences

- Prefer global `vp` with `pnpm` for JavaScript and TypeScript. Use `yarn` only in `~/dev/pre-script/` projects.
- Use `npm` only when compatibility or required semantics demand it.
- Prefer `uv` over `pip`; use `pip` only when required.
- Manage pi packages with `pi install`, `pi update`, and `pi remove`.
- Prefer global `vp` commands to local `pnpm exec` equivalents.

## Formatting

- Match the Neovim Conform configuration at `~/dotfiles/.config/nvim/lua/plugins/conform.lua`.
- Prefer the project's formatter command over a raw formatter binary.
- Do not use Prettier unless the project configures it.
- In Vite Plus projects, use `vp fmt`/oxfmt for supported web files; otherwise use the formatter selected by Conform.
- Use standard ecosystem formatters where appropriate, such as `rustfmt` for Rust.
- Use Svelte LSP formatting for Svelte files.
- Do not use pi-specific source formatters unless explicitly requested.
- Do not preserve non-canonical formatting to minimize a diff. Warn before editing if canonical formatting may create substantial churn.

## Configuration changes

- Treat `~/dotfiles` as the source of truth for user and system configuration.
- Inspect `~/dotfiles` before changing configuration, even when working in another repository.
- Prefer global changes in `~/dotfiles` unless the user requests repository-local scope.
- Do not edit generated or deployed files in `$HOME` unless explicitly requested.
- Do not expand the scope beyond related files or directories without approval.

## Dotfiles layout

- System configuration lives in `~/dotfiles/nix` and uses flake-based nix-darwin and home-manager modules.
- Stow-managed files live under `~/dotfiles` and are linked into `$HOME`.

## Applying global changes

- Prefer dry runs, previews, or diffs before mutation when practical.
- Never run commands that require `sudo` or may prompt for a password.
- Give the user exact commands for privileged operations, including rebuilds, rollbacks, garbage collection, generation deletion, and privileged nix/darwin commands.
- Clearly label privileged commands as user-run follow-up steps.
- Use the built-in read tool before editing relevant files.

## Response Style

- Always respond to the user in plain language in the ISO 24495-1:2023 standard.
