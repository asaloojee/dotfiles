# config for path and starship
set -gx PATH $PATH /run/current-system/sw/bin
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

# cloud-sql-proxy path
set -gx PATH $PATH /cloud-sql-proxy

# nix path?
set -gx PATH $PATH /nix/var/nix/profiles/default/bin/

alias ls="eza --icons=always"

# uutils-coreutils - WIP
# alias pwd="/run/current-system/sw/bin/uutils-pwd"

# yazi setup
export EDITOR="nvim"

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    set cwd (yazi $argv --cwd-file="$tmp")
    
    if test -n "$cwd" -a "$cwd" != "$PWD"
        cd -- "$cwd"
    end
    
    rm -f -- "$tmp"
end

# Zoxide initialization for Fish shell
zoxide init fish | source
alias cd="z"

# fish greeting
set fish_greeting ""

# set locale
set -x LC_ALL en_CA.UTF-8
set -x LANG en_CA.UTF-8

starship init fish | source
