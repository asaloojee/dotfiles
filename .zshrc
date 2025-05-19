# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/load zinit
source "${ZINIT_HOME}/zinit.zsh"

#oh-my-posh?
  eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/zen.toml)"

# Declare the variable
typeset -A ZSH_HIGHLIGHT_STYLES

# To have paths colored instead of underlined
ZSH_HIGHLIGHT_STYLES[path]=none

# Syntax highlighting in ZSH
zinit light zsh-users/zsh-syntax-highlighting
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=#87C471,bold
ZSH_HIGHLIGHT_STYLES[precommand]=fg=#87C471,bold
ZSH_HIGHLIGHT_STYLES[arg0]=fg=#87C471,bold


eval "$(zoxide init --cmd cd zsh)"

# history
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---- Eza (better ls) -----
alias ls="eza --icons=always"

# nix path?
export PATH=$PATH:/nix/var/nix/profiles/default/bin/

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# cloud-sql-proxy path
export PATH=$PATH:~/cloud-sql-proxy

# pip

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/asaloojee/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/asaloojee/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/asaloojee/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/asaloojee/google-cloud-sdk/completion.zsh.inc'; fi

# yazi setup
export EDITOR="nvim"

# enables terminal to navigate to the last folder yazi was in
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
