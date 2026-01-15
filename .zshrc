# ============================================================================
# Modern Zsh Configuration (Optimized for Speed)
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
# Essential Zsh Plugins (Turbo Mode - Load After Prompt)
# ----------------------------------------------------------------------------

# Syntax highlighting - load immediately after prompt
zinit ice wait lucid
zinit light zsh-users/zsh-syntax-highlighting

# Fish-like autosuggestions - load immediately after prompt
zinit ice wait lucid
zinit light zsh-users/zsh-autosuggestions

# Additional completions - can wait a bit longer
zinit ice wait"1" lucid
zinit light zsh-users/zsh-completions

# History substring search - load with keybindings
zinit ice wait lucid atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down"
zinit light zsh-users/zsh-history-substring-search

# FZF Tab completions - needs compinit first
zinit ice wait"1" lucid
zinit light Aloxaf/fzf-tab

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTFILE=$HOME/.zhistory
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY

# ----------------------------------------------------------------------------
# Completion System (Cached - Regenerates Once Per Day)
# ----------------------------------------------------------------------------
autoload -Uz compinit

if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt AUTO_MENU
setopt AUTO_LIST

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' squeeze-slashes true

# ----------------------------------------------------------------------------
# Key Bindings
# ----------------------------------------------------------------------------
bindkey -e
bindkey "^[[3~" delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Magic Space - Expand History (!! and !$)
bindkey ' ' magic-space

# Edit Command in Editor (Ctrl+X, Ctrl+E)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Copy current command buffer to clipboard (Ctrl+X, Ctrl+C)
function copy-buffer-to-clipboard() {
    echo -n "$BUFFER" | pbcopy
    zle -M "Copied to clipboard"
}
zle -N copy-buffer-to-clipboard
bindkey '^X^C' copy-buffer-to-clipboard

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------
export LC_ALL=en_CA.UTF-8
export LANG=en_CA.UTF-8
export EDITOR=nvim
export VISUAL=nvim

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/nix/var/nix/profiles/default/bin:$PATH"
export PATH="/run/current-system/sw/bin:$PATH"
export PATH="$HOME/google-cloud-sdk/bin:$PATH"

# ----------------------------------------------------------------------------
# Tool Integrations (Cached Init Scripts)
# ----------------------------------------------------------------------------
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"

# Zoxide
_zoxide_cache="$ZSH_CACHE_DIR/zoxide.zsh"
if [[ ! -f "$_zoxide_cache" || ! -s "$_zoxide_cache" || -n "$_zoxide_cache"(#qN.md+7) ]]; then
    command -v zoxide &>/dev/null && zoxide init zsh > "$_zoxide_cache"
fi
[[ -f "$_zoxide_cache" ]] && source "$_zoxide_cache"

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Transient Prompt
TRANSIENT_PROMPT=`starship module character`
zle-line-init() {
    emulate -L zsh

    [[ $CONTEXT == start ]] || return 0
    while true; do
        zle .recursive-edit
        local -i ret=$?
        [[ $ret == 0 && $KEYS == $'\4' ]] || break
        [[ -o ignore_eof ]] || exit 0
    done

    local saved_prompt=$PROMPT
    local saved_rprompt=$RPROMPT

    PROMPT=$TRANSIENT_PROMPT
    zle .reset-prompt
    PROMPT=$saved_prompt

    if (( ret )); then
        zle .send-break
    else
        zle .accept-line
    fi
    return ret
}
zle -N zle-line-init

# Google Cloud SDK completions (lazy loaded)
zinit ice wait"2" lucid if"[[ -f $HOME/google-cloud-sdk/completion.zsh.inc ]]"
zinit snippet "$HOME/google-cloud-sdk/completion.zsh.inc"

# ----------------------------------------------------------------------------
# Plugin Configuration
# ----------------------------------------------------------------------------
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

zstyle ':completion:*:git-checkout:*' sort false
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview 'if [[ -d $realpath ]]; then eza -1 --color=always $realpath; else bat --color=always --style=numbers --line-range=:500 $realpath 2>/dev/null || cat $realpath; fi'

# ----------------------------------------------------------------------------
# Suffix Aliases - Open Files by Extension
# ----------------------------------------------------------------------------
alias -s md=bat
alias -s txt=bat
alias -s log=bat
alias -s json=jless
alias -s py='$EDITOR'
alias -s js='$EDITOR'
alias -s ts='$EDITOR'
alias -s tsx='$EDITOR'
alias -s jsx='$EDITOR'
alias -s nix='$EDITOR'
alias -s html=open

# ----------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------

# Rebuild Nix Darwin system
function rebuild() {
    echo "❄️ Rebuilding Nix flake..."
    sudo -i darwin-rebuild switch --flake ~/dotfiles/nix#mac
}

# Yazi with directory tracking
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

# Caffeinate display (1-3 hours)
function caff() {
    local hours=${1:-1}
    [[ $hours =~ ^[1-3]$ ]] || { echo "Usage: caff [1-3]"; return 1; }
    echo "☕ Keeping display awake for $hours hour(s)..."
    caffeinate -d -t $((hours * 3600))
}

# Refresh cached init scripts
function zsh-refresh-cache() {
    echo "🔄 Refreshing zsh cache..."
    rm -f "$ZSH_CACHE_DIR"/*.zsh
    source ~/.zshrc
    echo "✅ Cache refreshed!"
}

# ----------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------
alias ls="eza --icons=always"
alias g="gitui"
alias mux="tmuxinator"
alias n="nvim"
alias cc="claude"
alias cd="z"
