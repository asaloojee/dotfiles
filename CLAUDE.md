# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a **Nix Darwin-based dotfiles repository** for macOS (Apple Silicon) that declaratively manages system configuration, applications, and development environment. It combines Nix flakes for package management with traditional dotfiles organized using GNU Stow.

## System Rebuild and Configuration

### Primary System Management

**Rebuild entire system:**

```bash
darwin-rebuild switch --flake ~/dotfiles/nix#mac
# Or use the alias:
rebuild
```

This single command:

- Installs/updates all Nix packages
- Manages Homebrew packages and casks
- Applies macOS system settings
- Garbage collects old generations

**Configuration location:** `nix/flake.nix`

### Dotfile Management

Dotfiles are symlinked using GNU Stow:

```bash
cd ~/dotfiles
stow .  # Creates symlinks in home directory
```

Stow configuration in `.stow-local-ignore` excludes `.git`, `.gitignore`, and `.DS_Store`.

## Architecture

### Hybrid Package Management

**Nix packages** (defined in `nix/flake.nix`):

- CLI development tools (neovim, tmux, git, gh, gitui, gitleaks)
- Language toolchains (go, rustup, uv for Python)
- Shell utilities (fish, zsh, bat, eza, fd, ripgrep, zoxide, yazi, starship)
- GUI apps (aerospace, brave, obsidian, raycast, zed-editor)
- Fonts (JetBrains Mono, Iosevka, Maple Mono, Meslo LG, Monaspace - all Nerd Font variants)

**Homebrew** (managed via Nix Darwin):

- Development tools (bun, composer, tailscale, docker-desktop, claude, claude-code)
- GUI applications (figma, ghostty, adobe-creative-cloud, proton suite, signal, zoom)
- Mac App Store apps (PDFgear via mas)
- Additional fonts (Hack Nerd Font, SF Mono/Pro, Martel, Playfair)

**Auto-cleanup:** Homebrew runs `zap` cleanup on activation, auto-updates enabled.

### Directory Structure

```
~/dotfiles/
├── nix/
│   ├── flake.nix          # System packages, Homebrew, macOS settings
│   └── flake.lock         # Locked dependencies
├── .config/
│   ├── aerospace/         # Window manager config
│   ├── fish/              # Fish shell (primary shell)
│   ├── ghostty/           # Terminal emulator config
│   ├── nvim/              # Neovim (LazyVim-based, see nvim/CLAUDE.md)
│   ├── sketchybar/        # macOS menu bar (currently disabled)
│   ├── starship/          # Shell prompt theme
│   ├── tmux/              # Terminal multiplexer config
│   ├── tmuxinator/        # Tmux session templates
│   └── yazi/              # Terminal file manager config
├── .zshrc                 # Zsh config (secondary shell)
└── .stow-local-ignore     # Stow exclusion patterns
```

## Shell Configuration

### Fish (Primary Shell)

**Config:** `.config/fish/config.fish`

**Key aliases and functions:**

- `rebuild` → `darwin-rebuild switch --flake ~/dotfiles/nix#mac`
- `cd` → `z` (zoxide smart directory jumping)
- `ls` → `eza` (modern ls replacement)
- `g` → `gitui` (terminal git UI)
- `mux` → `tmuxinator` (session manager)
- `n` → `nvim`
- `y` → `yazi` (file manager with directory tracking)

**Features:**

- Starship prompt integration
- Git wrapper enforces commands run from repo root
- PATH includes Nix, Homebrew, Cargo, Google Cloud SDK

### Zsh (Secondary Shell)

**Config:** `.zshrc`

**Features:**

- Zinit plugin manager
- oh-my-posh prompt (alternative to Starship)
- zsh-syntax-highlighting with custom colors
- Zoxide, NVM, Google Cloud SDK integration

## Development Environment

### Neovim

**See `.config/nvim/CLAUDE.md` for comprehensive Neovim documentation.**

Quick reference:

- LazyVim-based configuration
- LSP servers: vtsls (TS/JS), astro, css, html, json, lua, pyright
- Formatters: prettier (100 char, single quotes), stylua, ruff
- Completion: blink.cmp (not nvim-cmp)
- Debugging: nvim-dap with Python support
- Theme: Tokyo Night
- 2-space indentation, absolute line numbers
- Root detection disabled (stays in opened directory)

**Plugin management:**

```bash
:Lazy sync       # Update all plugins
:Mason           # Manage LSP servers and formatters
```

### Tmux

**Config:** `.config/tmux/tmux.conf`

**Key settings:**

- Prefix: `Ctrl+Space` (not Ctrl+B)
- Vi mode enabled
- Tokyo Night theme
- Base index starts at 1
- Mouse support enabled
- Vim-tmux navigation integration

**Plugin management:**

```bash
# Install/update plugins: Ctrl+Space + I
```

**Plugins:** tpm, tmux-sensible, vim-tmux-navigator, tokyo-night-tmux, tmux-yank

### Tmuxinator (Session Templates)

**Config directory:** `.config/tmuxinator/`

**Available sessions:**

- `dev.yml` - General development (3 windows: editor, claude, terminal)
- `omniwerx-io.yml` - Omniwerx project workspace
- `pre-script-web.yml` - Pre-script web project
- `langchain-course.yml` - Learning project
- `ts-course.yml` - TypeScript course

**Usage:**

```bash
mux start dev              # Start session
mux list                   # List available sessions
mux edit dev               # Edit session config
```

### Terminal (Ghostty)

**Config:** `.config/ghostty/config`

**Settings:**

- Font: JetBrainsMono Nerd Font, size 18
- Theme: tokyonight
- Background: 90% opacity with blur
- Shell: fish
- Window padding: 12px horizontal, 0/8px vertical

## Window Management

### AeroSpace (Tiling Window Manager)

**Config:** `.config/aerospace/aerospace.toml`

**Features:**

- i3/sway-like tiling for macOS
- Keybindings: `Alt+Ctrl+Cmd` prefix
- 5 workspaces with app auto-assignment
- Gaps: 8px inner and outer

**Workspace assignments:**

- 1: Brave, Proton Mail
- 2: Safari, Claude (todesktop)
- 3: Figma
- 4: Slack
- 5: Music, Spotify (floating)

**Floating windows:** Finder, Messages, ProtonVPN

## macOS System Settings (via Nix)

**Dock:**

- Auto-hide enabled, static apps only, 16px tile size

**Finder:**

- Path bar and all extensions shown
- Column view, new windows open in Documents

**System:**

- Dark mode forced
- Fast key repeat (2)
- Guest account disabled
- Clock shows seconds
- Auto macOS updates enabled

**Maintenance:**

- Garbage collection: Weekly Monday 3am (keep 30 days)
- Store optimization: Weekly Monday 4am

## Common Workflows

### Initial System Setup

1. Clone repository: `git clone <repo> ~/dotfiles`
2. Install Nix and nix-darwin (if not already installed)
3. Rebuild system: `darwin-rebuild switch --flake ~/dotfiles/nix#mac`
4. Stow dotfiles: `cd ~/dotfiles && stow .`
5. Launch tmux (plugins auto-install via TPM)
6. Launch Neovim (plugins auto-install via lazy.nvim, Mason tools auto-install)

### Daily Development Workflow

1. Launch Ghostty terminal (Fish shell)
2. Navigate: `z <project-name>` (zoxide)
3. Start session: `mux start <project>`
4. Edit: `n` or `nvim`
5. File browsing: `y` (yazi)
6. Git operations: `g` (gitui) or `git` (enforced from repo root)
7. Window management: `Alt+Ctrl+Cmd+hjkl` (AeroSpace)

### Updating the System

**Update all packages and rebuild:**

```bash
rebuild
```

**Update specific components:**

```bash
# Neovim plugins
:Lazy sync

# Mason tools (LSP/formatters)
:Mason
:MasonUpdate

# Tmux plugins
# In tmux: Ctrl+Space + I
```

**Update flake dependencies:**

```bash
cd ~/dotfiles/nix
nix flake update
darwin-rebuild switch --flake .#mac
```

### Adding New Packages

**Nix packages:**

1. Edit `nix/flake.nix`
2. Add package to `environment.systemPackages`
3. Run `rebuild`

**Homebrew packages:**

1. Edit `nix/flake.nix`
2. Add to `homebrew.brews`, `homebrew.casks`, or `homebrew.masApps`
3. Run `rebuild`

### Creating New Tmuxinator Sessions

1. Create config: `mux new <project-name>`
2. Edit template in `.config/tmuxinator/<project-name>.yml`
3. Start session: `mux start <project-name>`

Typical layout (see `dev.yml` for reference):

```yaml
windows:
  - editor:
      layout: main-vertical
      panes:
        - nvim
  - claude:
  - terminal:
```

## Language-Specific Configuration

### TypeScript/JavaScript

- LSP: vtsls (configured in `nvim/lua/plugins/lspconfig.lua`)
- Formatter: prettier (100 char width, single quotes)
- Runtime: Bun (via Homebrew)
- Astro files: Handled by astro LSP, not vtsls

### Python

- LSP: pyright (auto-detects `.venv` in cwd)
- Formatter: ruff
- Package manager: uv (via Nix)
- Debugger: debugpy (configured in `nvim/lua/plugins/dap-python.lua`)
- Virtual env: Must be named `.venv` in project root

### Lua

- LSP: lua_ls (Neovim API support)
- Formatter: stylua (100 char width, 2-space indent)
- Config: `stylua.toml`

### Go

- Toolchain: go (via Nix)

### Rust

- Toolchain: rustup (via Nix)

## Key Architectural Patterns

### Declarative System State

The entire system configuration is declarative in `nix/flake.nix`. Changes are:

1. Edit flake configuration
2. Run `rebuild`
3. System atomically transitions to new state
4. Rollback available via Nix generations: `darwin-rebuild switch --rollback`

### Modular Configuration

Each tool has dedicated config directory under `.config/`. Neovim plugins split into individual files in `nvim/lua/plugins/`. Tmuxinator templates per project.

### Theme Consistency

Tokyo Night theme across:

- Terminal (Ghostty)
- Neovim
- Tmux
- Starship prompt

JetBrainsMono Nerd Font used everywhere.

### Shell Integration

Consistent aliases across Fish and Zsh. Tool wrappers (git, yazi) enhance functionality. Environment-aware configurations (Nix paths, Google Cloud SDK).

## Important Notes

### Git Workflow

The Fish shell has a custom git wrapper that enforces running git commands from the repository root. This prevents accidentally running git commands in subdirectories.

### Shell Usage (Claude Code)

**IMPORTANT:** Claude Code uses Zsh, not Fish. The `cd` command is aliased to `zoxide` (`__zoxide_z`) in `.zshrc`, but Claude Code's shell snapshots don't capture all zoxide internals, causing `cd` to fail.

**Solution:** Always use `builtin cd` instead of `cd` in bash commands only when Claude Code executes commands:

```bash
# Correct
builtin cd /path/to/dir && command

# Incorrect - will fail
cd /path/to/dir && command
```

### Root Directory Behavior (Neovim)

Neovim stays in the directory where it was opened rather than jumping to project roots:

```lua
vim.g.root_spec = { "cwd" }
```

### Python Virtual Environments

The config expects virtual environments named `.venv` in the project root. Pyright and debugpy auto-detect this location.

### Commit Style

This repository uses informal, casual commit messages. Don't be surprised by messages like "nvim > zed > cursor" or "python debugging or something. idc".

## Troubleshooting

### Nix Build Failures

```bash
# Check flake inputs
nix flake metadata ~/dotfiles/nix

# Update flake lock
cd ~/dotfiles/nix
nix flake update

# Clean build
darwin-rebuild switch --flake ~/dotfiles/nix#mac --recreate-lock-file
```

### LSP Not Working in Neovim

```bash
# Check LSP status
:LspInfo

# Reinstall tools
:Mason
# Press 'U' to update all tools
```

### Stow Conflicts

```bash
# Remove existing dotfile first
rm ~/.zshrc

# Then re-stow
cd ~/dotfiles
stow .
```

### Tmux Plugins Not Installing

```bash
# In tmux, press: Ctrl+Space + I
# Or manually:
~/.config/tmux/plugins/tpm/bin/install_plugins
```

### Removed Apps Still Opening Files (Launch Services Issue)

If you remove an app from Nix (like Cursor or VS Code) but it still opens when you double-click files, it's because:

1. Old Nix Darwin generations still reference the app (keeping it in `/nix/store/`)
2. macOS Launch Services database has stale file associations

**Fix:**

```bash
# Delete old system generations
sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Garbage collect to remove app from Nix store
sudo nix-collect-garbage -d

# Rebuild Launch Services database
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user

# Restart Finder if needed
killall Finder
```

## Platform Information

- **System**: macOS (Apple Silicon - aarch64-darwin)
- **Nix Darwin State Version**: 6
- **Primary Shell**: Fish
- **Terminal**: Ghostty
- **Window Manager**: AeroSpace
