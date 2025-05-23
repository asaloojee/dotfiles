# config for path and starship
set -gx PATH $PATH /run/current-system/sw/bin
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

# cloud-sql-proxy path
set -gx PATH $PATH /cloud-sql-proxy

# nix path?
set -gx PATH $PATH /nix/var/nix/profiles/default/bin/

function fish_command_not_found
    echo -e "\033[31mCommand not found: $argv\033[0m"
end

alias ls="eza --icons=always"

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

starship init fish | source
