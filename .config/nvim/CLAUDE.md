# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration built on top of LazyVim, optimized for web development (JavaScript/TypeScript/React/Astro) and Python. The configuration uses lazy.nvim as the plugin manager and follows LazyVim's modular structure.

## Architecture

### Directory Structure

- `init.lua` - Entry point that bootstraps the config by requiring `config.lazy`
- `lua/config/` - Core configuration files
  - `lazy.lua` - Plugin manager setup and LazyVim bootstrap
  - `options.lua` - Vim options (indent, folding, line numbers)
  - `keymaps.lua` - Custom key mappings
  - `autocmds.lua` - Autocommands (format options, etc.)
- `lua/plugins/` - Plugin specifications (each file is auto-loaded by lazy.nvim)
- `lua/configs/` - Configuration modules used by plugins (e.g., mason tool list)
- `snippets/` - Custom snippets
- `lazy-lock.json` - Plugin version lockfile

### Plugin Loading System

The configuration uses LazyVim's plugin structure where:
1. LazyVim core plugins are imported via `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }`
2. LazyVim extras are selectively imported (e.g., `lazyvim.plugins.extras.util.rest`)
3. Custom plugins in `lua/plugins/*.lua` are auto-imported via `{ import = "plugins" }`
4. Each file in `lua/plugins/` returns a table or array of plugin specs

## Language Server Configuration

### LSP Setup Pattern

All LSP servers are configured in `lua/plugins/lspconfig.lua` with a consistent pattern:
- Capabilities are extended with `blink.cmp` completions
- Diagnostics use custom icons and hide in insert mode
- Each server has specific settings for optimal behavior

### Configured Language Servers

- **vtsls** - TypeScript/JavaScript (excludes .astro files)
- **astro** - Astro framework files
- **cssls** - CSS/SCSS/Less
- **cssmodules_ls** - CSS Modules in JS/TS files
- **html** - HTML and Astro
- **jsonls** - JSON/JSONC
- **lua_ls** - Lua with Neovim API support
- **pyright** - Python with virtual environment detection

### Key LSP Behaviors

- Diagnostics automatically hide on `InsertEnter` and show on `InsertLeave`
- Python LSP auto-detects `.venv` directories in the current working directory
- TypeScript LSP has inlay hints disabled for cleaner UI
- Astro files are handled by the Astro LSP, not vtsls

## Formatting

Formatting is handled by `conform.nvim` with these formatters:
- **prettier** - JS/TS/React/Vue/CSS/HTML/JSON/YAML/Markdown (100 char width, single quotes)
- **stylua** - Lua (100 char width)
- **ruff_format** - Python
- **Astro LSP** - Astro files use LSP formatting

Format with `<leader>cf` in normal or visual mode.

## Completion

Uses `blink.cmp` (not nvim-cmp) for completions:
- Tab key selects and accepts completions
- Enter key accepts completions
- Documentation auto-show is disabled
- Sources: LSP, path, snippets, buffer
- Cmdline completion is disabled

## Debugging (DAP)

Debugging is configured using nvim-dap with the Debug Adapter Protocol. The setup includes:
- **nvim-dap** - Core DAP client
- **nvim-dap-ui** - Debugging UI with breakpoints, variables, call stack, and console
- **nvim-dap-python** - Python debugging with debugpy
- **nvim-dap-virtual-text** - Inline variable display during debugging

### Python Debugging Setup

Python debugging automatically uses:
- `.venv/bin/python` if a virtual environment exists in the project root
- System `python3` or `python` as fallback

The debugpy adapter is configured in `lua/plugins/dap-python.lua`.

### Debugging Key Mappings

**General DAP:**
- `<leader>db` - Toggle breakpoint
- `<leader>dB` - Set conditional breakpoint
- `<leader>dc` - Continue execution
- `<leader>dC` - Run to cursor
- `<leader>dg` - Go to line (without executing)
- `<leader>di` - Step into
- `<leader>do` - Step out
- `<leader>dO` - Step over
- `<leader>dp` - Pause execution
- `<leader>dr` - Toggle REPL
- `<leader>ds` - Session menu
- `<leader>dt` - Terminate session
- `<leader>dw` - Widgets menu
- `<F5>` - Continue/start debugging
- `<F10>` - Step over
- `<F11>` - Step into
- `<F12>` - Step out

**Python-Specific:**
- `<leader>dpr` - Debug Python test method (under cursor)
- `<leader>dpc` - Debug Python test class

### Debugging Workflow

1. Open a Python file
2. Set breakpoints with `<leader>db`
3. Start debugging with `<F5>` or `<leader>dc`
4. Use step commands to navigate through code
5. Inspect variables in the DAP UI
6. Terminate with `<leader>dt`

The DAP UI automatically opens when a debug session starts, showing:
- Scopes (local/global variables)
- Breakpoints list
- Call stack
- Debug console

## Mason Tool Management

Tools are automatically installed via `mason-tool-installer.nvim` using the list in `lua/configs/mason.lua`:

**LSP Servers:**
- css-lsp, cssmodules-language-server, vtsls, astro-language-server
- html-lsp, json-lsp, lua-language-server, pyright

**Formatters:**
- prettier, stylua, ruff

## Development Workflow

### Checking Plugin Status
```bash
nvim
:Lazy
```

### Installing/Updating Tools
Mason tools are auto-installed on startup. To manually manage:
```bash
:Mason
:MasonUpdate
```

### Updating Plugins
```bash
:Lazy sync  # Update all plugins
:Lazy update  # Update specific plugins
```

### Treesitter Management
Parsers are auto-installed for configured languages. To manually install:
```bash
:TSUpdate
:TSInstall <language>
```

### Formatting Code
- In normal/visual mode: `<leader>cf`
- Prettier is used for most web languages
- Configuration: `lua/plugins/conform.lua`

## Configuration Patterns

### Adding a New LSP Server

1. Add server to `lua/configs/mason.lua` ensure_installed list
2. Configure in `lua/plugins/lspconfig.lua`:
```lua
lspconfig.server_name.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "filetype" },
  settings = {
    -- Server-specific settings
  },
})
```

### Adding a New Plugin

Create `lua/plugins/plugin-name.lua`:
```lua
return {
  "author/plugin-name",
  opts = {
    -- configuration
  },
}
```

### Modifying Key Mappings

Edit `lua/config/keymaps.lua`:
```lua
vim.keymap.set("mode", "key", function() ... end, { desc = "Description" })
```

## Important Configuration Details

### Root Directory Behavior

The config disables LazyVim's automatic root detection:
```lua
vim.g.root_spec = { "cwd" }
```
Neovim stays in the directory where it was opened, rather than jumping to project roots.

### Indentation Settings

Default indentation is 2 spaces across all file types:
- `tabstop = 2`
- `softtabstop = 2`
- `shiftwidth = 2`
- `expandtab = true`

### Folding

Treesitter-based folding is enabled with all folds open by default (`foldlevelstart = 99`).

### Line Numbers

Configured to use absolute line numbers (not relative):
```lua
vim.opt.number = true
vim.opt.relativenumber = false
```

### Comment Continuation

Auto-comment continuation is disabled for all file types via autocmd in `lua/config/autocmds.lua`.

## Styling and Formatting Tools

- **stylua.toml** - Lua formatting config (2-space indent, 120 char width)
- **Prettier** - Web language formatting (single quotes, 100 char width)

## Plugin Ecosystem

Key plugins beyond LazyVim defaults:
- **blink.cmp** - Fast completion engine (replaces nvim-cmp)
- **conform.nvim** - Formatting
- **mason.nvim + mason-tool-installer.nvim** - LSP/tool management
- **nvim-treesitter** - Syntax highlighting and code understanding
- **nvim-dap + nvim-dap-ui** - Debugging with DAP (LazyVim extra)
- **nvim-dap-python** - Python debugging support
- **noice.nvim** - Enhanced UI for messages/cmdline
- **kulala.nvim** - REST client (LazyVim extra)

## Troubleshooting

### LSP Not Attaching

Check if the LSP is installed:
```bash
:Mason
```

Verify LSP is running:
```bash
:LspInfo
```

### Formatter Not Working

Ensure the formatter is installed via Mason and configured in `lua/plugins/conform.lua`.

### Python Virtual Environment Not Detected

The config looks for `.venv` in the current working directory. Ensure:
1. Virtual environment is named `.venv`
2. Located in the root of your project
3. Neovim was opened from the project root

### Python Debugger Not Working

Ensure debugpy is installed in your Python environment:
```bash
# If using a virtual environment
source .venv/bin/activate
pip install debugpy

# Or globally
pip install debugpy
```

Check DAP status:
```bash
:checkhealth dap
```
