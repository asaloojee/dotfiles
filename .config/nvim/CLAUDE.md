# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

LazyVim v8-based Neovim configuration. Lean setup that overrides only what's needed from the LazyVim defaults — colorscheme, completion, LSP, formatters, Telescope, lualine, and Treesitter parsers. All keybindings are LazyVim defaults (no custom keymaps).

## Commands

```bash
# Update plugins
nvim --headless "+Lazy! sync" +qa

# Check plugin status
:Lazy

# Manage LSP servers/formatters
:Mason

# Check LSP status for current buffer
:LspInfo

# Check formatter for current buffer
:ConformInfo

# View loaded LazyVim extras
:LazyExtras
```

## Architecture

Entry point is `init.lua` → `require("config.lazy")` which bootstraps lazy.nvim and loads plugins.

```
lua/
├── config/
│   ├── lazy.lua        # lazy.nvim bootstrap + plugin spec loader
│   ├── options.lua     # Vim options (loaded before lazy.nvim)
│   └── autocmds.lua    # Single autocmd: disables comment continuation
└── plugins/
    ├── colorscheme.lua # Tokyo Night (night variant)
    ├── completion.lua  # blink.cmp (NOT nvim-cmp)
    ├── conform.lua     # Formatters: prettier, stylua, ruff_format
    ├── devicons.lua    # Auto-colors icons to match theme
    ├── lspconfig.lua   # LSP servers: cssls, cssmodules_ls, html, eslint, pyright
    ├── lualine.lua     # Status line with powerline separators
    ├── noice.lua       # Disabled
    ├── telescope.lua   # Shows hidden files, ignores .git/ and .DS_Store
    └── treesitter.lua  # Additional parsers beyond LazyVim defaults
```

Each plugin file in `lua/plugins/` either overrides or extends a LazyVim default. Plugins not listed here come from LazyVim or its extras.

## LazyVim Extras

Enabled in `lazyvim.json`:
- `lang.astro` — Astro LSP
- `lang.json` — jsonls + SchemaStore
- `lang.markdown` — Markdown tooling + preview
- `lang.typescript` — vtsls (not tsserver)
- `linting.eslint` — ESLint as LSP

These extras provide LSP servers, Treesitter parsers, and formatters automatically. Don't duplicate their config in plugin files.

## Key Design Decisions

- **Completion engine is blink.cmp**, not nvim-cmp. Do not add nvim-cmp plugins or config.
- **Root detection disabled**: `vim.g.root_spec = { "cwd" }` — Neovim stays in the opened directory. No project root jumping.
- **Absolute line numbers** (not relative).
- **Prettier runs without a project config**: `vim.g.lazyvim_prettier_needs_config = false`.
- **No DAP/debugger config** — was removed in a previous cleanup.
- **Noice.nvim is disabled** — the plugin is present but `enabled = false`.
- **Comment continuation disabled** — autocmd removes `c`, `r`, `o` from formatoptions.

## LSP Servers

Explicitly configured in `lspconfig.lua`:
- **cssls** — ignores unknown at-rules (for Tailwind's `@apply`, `@tailwind`)
- **cssmodules_ls** — go-to-definition for CSS modules, `camelCase = "dashes"`
- **html** — filetypes restricted to `html` only
- **eslint** — defaults
- **pyright** — workspace diagnostics, basic type checking, auto-detects `.venv/bin/python`

Additional servers from LazyVim extras: `vtsls`, `astro`, `jsonls`, `lua_ls`.

## Formatters (conform.nvim)

| Filetype | Formatter | Notes |
|---|---|---|
| JS/TS/JSX/TSX/Vue, CSS/SCSS, HTML, JSON/YAML/MD | prettier | `--single-quote --print-width 100` |
| Astro | LSP format (prefer) | Falls back to prettier |
| Lua | stylua | `--column-width 100` (overrides stylua.toml's 120) |
| Python | ruff_format | |

Default: `lsp_format = "fallback"` — uses LSP formatting if no formatter is configured.

## Lua Code Style

`stylua.toml`: 2-space indentation, spaces (not tabs). The conform.lua config overrides column width to 100 at runtime despite stylua.toml saying 120.

## Adding a New Plugin

Create a new file in `lua/plugins/` returning a lazy.nvim plugin spec table. LazyVim auto-discovers all files in that directory. Use `lazy = false` sparingly — most plugins should lazy-load.

## Adding a New LSP Server

Add to the `servers` table in `lua/plugins/lspconfig.lua`. Mason auto-installs servers listed there. For language-specific extras (like astro, typescript), prefer enabling the LazyVim extra in `lazyvim.json` over manual config.
