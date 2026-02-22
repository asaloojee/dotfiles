# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration built on top of LazyVim, optimized for web development (JavaScript/TypeScript/React/Astro) and Python. The configuration uses lazy.nvim as the plugin manager and follows LazyVim's modular structure.

## Architecture

### Directory Structure

- `init.lua` - Entry point that bootstraps the config by requiring `config.lazy`
- `lua/config/` - Core configuration files
  - `lazy.lua` - Plugin manager setup and LazyVim bootstrap
  - `options.lua` - Vim options (folding, line numbers, formatting behavior)
  - `autocmds.lua` - Autocommands (disables comment continuation)
- `lua/plugins/` - Plugin specifications (each file is auto-loaded by lazy.nvim)
- `lazyvim.json` - Tracks enabled LazyVim extras (managed via `:LazyExtras` UI)
- `lazy-lock.json` - Plugin version lockfile
- `stylua.toml` - Lua formatter config

### Plugin Loading System

1. LazyVim core plugins imported via `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }`
2. `lazy.lua` imports `lazyvim.plugins.extras.util.rest` (kulala REST client)
3. `lazyvim.json` enables extras: `lang.typescript`, `lang.json`, `lang.markdown`
4. Custom plugins in `lua/plugins/*.lua` auto-imported via `{ import = "plugins" }`

## Language Server Configuration

### LSP Setup

All LSP servers are configured in `lua/plugins/lspconfig.lua` using LazyVim's `opts.servers` table pattern (not manual `lspconfig.X.setup()` calls). LazyVim handles `on_attach` and capabilities automatically.

### Configured Servers

- **vtsls** - TypeScript/JavaScript (returns `nil` root_dir for `.astro` files to avoid conflict)
- **astro** - Astro framework (uses local project TypeScript SDK from `node_modules/`)
- **cssls** - CSS/SCSS/Less (ignores unknown at-rules for Tailwind compatibility)
- **cssmodules_ls** - CSS Modules in JS/TS files (`camelCase = "dashes"`)
- **html** - HTML and Astro
- **jsonls** - JSON/JSONC (configured by LazyVim lang.json extra)
- **lua_ls** - Lua (configured by LazyVim defaults, not customized here)
- **pyright** - Python with `.venv` auto-detection, `typeCheckingMode = "basic"`

## Formatting

- **Format-on-save is disabled** (`vim.g.autoformat = false`). Format manually with `<leader>cf`.
- **Prettier runs without project config** (`vim.g.lazyvim_prettier_needs_config = false`)
- LSP formatting is used as fallback when no formatter matches

Formatters:
- **prettier** - JS/TS/React/Vue/CSS/SCSS/LESS/HTML/JSON/YAML/Markdown (100 char width, single quotes)
- **stylua** - Lua (conform.nvim overrides to 100 char width via `--column-width 100`; `stylua.toml` says 120)
- **ruff_format** - Python
- **Astro LSP** - Astro files use LSP formatting

## Completion

Uses `blink.cmp` v1.x (not nvim-cmp):
- Tab/Enter to accept completions
- Documentation auto-show disabled
- Sources: LSP, path, buffer (no snippets source)
- Auto-trigger on special characters disabled (`show_on_trigger_character = false`)
- Cmdline completion disabled
- Rust-based fuzzy matching preferred

## Debugging (DAP)

Python debugging via nvim-dap + nvim-dap-python + debugpy:
- Uses `.venv/bin/python` if available, falls back to system python
- DAP UI opens automatically on debug session start

Key mappings: `<leader>db` (breakpoint), `<leader>dc` (continue), `<leader>di/do/dO` (step into/out/over), `<leader>dt` (terminate), `<F5>` (continue/start)

Python-specific: `<leader>dpr` (debug test method), `<leader>dpc` (debug test class)

## Important Configuration Details

### Key Behavioral Settings

- **Root detection disabled**: `vim.g.root_spec = { "cwd" }` - stays in opened directory
- **Absolute line numbers** (not relative)
- **Treesitter folding** with all folds open by default (`foldlevelstart = 99`)
- **Comment continuation disabled** via autocmd
- **noice.nvim is disabled** (`enabled = false`)
- **Indentation**: 2 spaces (inherited from LazyVim defaults, not explicitly set in options.lua)

### Theme

Tokyo Night (`tokyonight-night` variant) with custom font styles:
- Comments: italic
- Keywords: italic + bold
- Functions: bold

### Custom UI

- **lualine.lua** - Custom statusline with powerline-style separators (`` / ``), shows: mode, branch, filename, encoding, filetype, progress, location
- **devicons.lua** - `tiny-devicons-auto-colors.nvim` matches file icons to Tokyo Night palette
- **telescope.lua** - Shows hidden files, ignores `.git/` and `.DS_Store`

## Configuration Patterns

### Adding a New LSP Server

Configure in `lua/plugins/lspconfig.lua` using the LazyVim opts pattern:
```lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      server_name = {
        filetypes = { "filetype" },
        settings = { ... },
      },
    },
  },
}
```

### Adding a New Plugin

Create `lua/plugins/plugin-name.lua`:
```lua
return {
  "author/plugin-name",
  opts = { ... },
}
```

### Adding Key Mappings

Create or edit `lua/config/keymaps.lua` (does not currently exist - no custom keymaps defined):
```lua
vim.keymap.set("mode", "key", function() ... end, { desc = "Description" })
```

## Troubleshooting

- **LSP not attaching**: Check `:Mason` for installation, `:LspInfo` for status
- **Formatter not working**: Verify installed via Mason, check `lua/plugins/conform.lua`
- **Python venv not detected**: Must be named `.venv` in project root, open Neovim from project root
- **Python debugger**: Install debugpy in venv (`pip install debugpy`), check `:checkhealth dap`
