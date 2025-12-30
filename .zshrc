# ============================================================================
# Modern Zsh Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Zinit Plugin Manager Setup
# ----------------------------------------------------------------------------
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if not installed
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load Zinit
source "${ZINIT_HOME}/zinit.zsh"

# ----------------------------------------------------------------------------
# Essential Zsh Plugins
# ----------------------------------------------------------------------------

# Syntax highlighting (must be loaded before autosuggestions)
zinit light zsh-users/zsh-syntax-highlighting

# Fish-like autosuggestions
zinit light zsh-users/zsh-autosuggestions

# Additional completions
zinit light zsh-users/zsh-completions

# History substring search (up/down arrows search history)
zinit light zsh-users/zsh-history-substring-search

# FZF Tab completions (prettier tab completions)
zinit light Aloxaf/fzf-tab

# ----------------------------------------------------------------------------
# Syntax Highlighting Styles
# ----------------------------------------------------------------------------
typeset -A ZSH_HIGHLIGHT_STYLES

# Commands and aliases - green and bold
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[command]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[builtin]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[function]=fg=green,bold

# Paths - no underline
ZSH_HIGHLIGHT_STYLES[path]=none

# Errors - red
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red,bold

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTFILE=$HOME/.zhistory
HISTSIZE=10000
SAVEHIST=10000

# History options
setopt SHARE_HISTORY              # Share history across all sessions
setopt HIST_EXPIRE_DUPS_FIRST     # Expire duplicate entries first
setopt HIST_IGNORE_ALL_DUPS       # Delete old duplicates
setopt HIST_FIND_NO_DUPS          # Don't display duplicates in search
setopt HIST_IGNORE_SPACE          # Don't record entries starting with space
setopt HIST_VERIFY                # Show command with history expansion before running
setopt INC_APPEND_HISTORY         # Write to history file immediately

# ----------------------------------------------------------------------------
# Completion System
# ----------------------------------------------------------------------------

# Load and initialize completion system
autoload -Uz compinit
compinit

# Completion options
setopt COMPLETE_IN_WORD           # Complete from both ends of word
setopt ALWAYS_TO_END              # Move cursor to end after completion
setopt AUTO_MENU                  # Show completion menu on tab
setopt AUTO_LIST                  # Automatically list choices on ambiguous completion

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # Case-insensitive completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colored completion
zstyle ':completion:*' menu select                       # Arrow key navigation
zstyle ':completion:*' squeeze-slashes true              # Normalize slashes

# ----------------------------------------------------------------------------
# Key Bindings
# ----------------------------------------------------------------------------

# Use emacs keybindings (or set to -v for vi mode)
bindkey -e

# History search with up/down arrows
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Delete key
bindkey "^[[3~" delete-char

# Home/End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------

# Locale
export LC_ALL=en_CA.UTF-8
export LANG=en_CA.UTF-8

# Editor
export EDITOR=nvim
export VISUAL=nvim

# PATH - order matters (earlier = higher priority)
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
export PATH="/run/current-system/sw/bin:$PATH"
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

# ----------------------------------------------------------------------------
# Tool Integrations
# ----------------------------------------------------------------------------

# Zoxide (smarter cd)
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Starship prompt
if command -v starship &> /dev/null; then
    export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
    eval "$(starship init zsh)"
fi

# Google Cloud SDK completions
if [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# ----------------------------------------------------------------------------
# Autosuggestions Configuration
# ----------------------------------------------------------------------------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ----------------------------------------------------------------------------
# FZF Tab Configuration
# ----------------------------------------------------------------------------
# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# Preview directory contents with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Preview files and directories
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then eza -1 --color=always $realpath; else bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath; fi'

# ============================================================================
# ZSH Hacks (Dreams of Code)
# ============================================================================

# ----------------------------------------------------------------------------
# Edit Command in Editor (Ctrl+X, Ctrl+E)
# ----------------------------------------------------------------------------
# Open current command line in $EDITOR for complex edits
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# ----------------------------------------------------------------------------
# Magic Space - Expand History
# ----------------------------------------------------------------------------
# Expands history expressions like !! or !$ when you press space
bindkey ' ' magic-space

# ----------------------------------------------------------------------------
# zmv - Batch Rename/Move Tool
# ----------------------------------------------------------------------------
autoload -Uz zmv

# Usage examples:
# zmv '(*).log' '$1.txt'           # Rename .log to .txt
# zmv -w '*.log' '*.txt'           # Same, simpler syntax
# zmv -n '(*).log' '$1.txt'        # Dry run (preview)
# zmv -C '*.txt' 'backup/*.txt'    # Copy with patterns
# zmv -L '*.txt' 'links/*.txt'     # Link with patterns

# ----------------------------------------------------------------------------
# Named Directories - Quick Bookmarks
# ----------------------------------------------------------------------------
hash -d dot=~/dotfiles
hash -d dl=~/Downloads
hash -d doc=~/Documents

# Usage: cd ~dot, ls ~dl, etc.

# ----------------------------------------------------------------------------
# Custom Widgets
# ----------------------------------------------------------------------------

# Clear screen and scrollback (Ctrl+X, Ctrl+L)
function clear-screen-and-scrollback() {
  echoti civis >"$TTY"
  printf '%b' '\e[H\e[2J\e[3J' >"$TTY"
  echoti cnorm >"$TTY"
  zle redisplay
}
zle -N clear-screen-and-scrollback
bindkey '^X^L' clear-screen-and-scrollback

# Copy current command buffer to clipboard (Ctrl+X, Ctrl+C)
function copy-buffer-to-clipboard() {
  echo -n "$BUFFER" | pbcopy
  zle -M "Copied to clipboard"
}
zle -N copy-buffer-to-clipboard
bindkey '^X^C' copy-buffer-to-clipboard

# ----------------------------------------------------------------------------
# Suffix Aliases - Open Files by Extension
# ----------------------------------------------------------------------------
# Type filename to open it with the associated program
alias -s md=bat
alias -s txt=bat
alias -s log=bat
alias -s json=jless
alias -s py='$EDITOR'
alias -s js='$EDITOR'
alias -s ts='$EDITOR'
alias -s tsx='$EDITOR'
alias -s jsx='$EDITOR'
alias -s html=open  # macOS: open in default browser

# ----------------------------------------------------------------------------
# Global Aliases - Use Anywhere in Commands
# ----------------------------------------------------------------------------
alias -g NE='2>/dev/null'           # Redirect stderr to /dev/null
alias -g NO='>/dev/null'            # Redirect stdout to /dev/null
alias -g NUL='>/dev/null 2>&1'      # Redirect both to /dev/null
alias -g J='| jq'                   # Pipe to jq
alias -g C='| pbcopy'               # Copy output to clipboard (macOS)

# Usage: cat file.json J
#        echo "hello" C
#        ls /nonexistent NUL

# ----------------------------------------------------------------------------
# Git Hotkey Insertions
# ----------------------------------------------------------------------------
bindkey -s '^Xgc' 'git commit -m ""\C-b'          # Ctrl+X, G, C

# ============================================================================
# Custom Functions and Aliases (From Fish Config)
# ============================================================================

# ----------------------------------------------------------------------------
# System Management
# ----------------------------------------------------------------------------

# Rebuild Nix Darwin system configuration
function rebuild() {
    echo "🔄 Rebuilding Nix flake..."
    sudo -i darwin-rebuild switch --flake ~/dotfiles/nix#mac
}

# ----------------------------------------------------------------------------
# File and Directory Navigation
# ----------------------------------------------------------------------------

# Yazi file manager with directory changing
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [[ -n "$cwd" ]] && [[ "$cwd" != "$PWD" ]]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Jump to git repository root
function gr() {
    local root=$(command git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$root" ]]; then
        builtin cd "$root"
    else
        echo "Not in a git repository"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# Utilities
# ----------------------------------------------------------------------------

# Caffeinate display for specified hours (1-3)
function caff() {
    local hours=${1:-1}
    [[ $hours =~ ^[1-3]$ ]] || { echo "Usage: caff [1-3]"; return 1; }
    echo "☕ Keeping display awake for $hours hour(s)..."
    caffeinate -d -t $((hours * 3600))
}

# ============================================================================
# General Aliases
# ============================================================================

alias ls="eza --icons=always"
alias g="gitui"
alias mux="tmuxinator"
alias n="nvim"
alias cc="claude"
alias cd="z"
