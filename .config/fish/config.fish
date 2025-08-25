# config for path and starship
set -gx PATH $PATH /run/current-system/sw/bin
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

# cloud-sql-proxy path
set -gx PATH $PATH /cloud-sql-proxy
set -gx PATH $HOME/google-cloud-sdk/bin $PATH

# nix path?
set -gx PATH $PATH /nix/var/nix/profiles/default/bin/

# rust path
set -gx PATH $PATH /Users/asaloojee/.cargo/bin

alias ls="eza --icons=always"
alias g="gitui"

# uutils-coreutils - WIP
# alias pwd="/run/current-system/sw/bin/uutils-pwd"

# yazi setup
export EDITOR="nvim"

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

function lcd
    # Run lstr and capture the selected path
    set -l selected_dir (lstr interactive -g --icons)

    # If the user selected a path (and didn't just quit), `cd` into it
    # Check if the selection is a directory
    if test -n "$selected_dir" -a -d "$selected_dir"
        cd "$selected_dir"
    end
end

# Zoxide initialization for Fish shell
zoxide init fish | source
alias cd="z"

# git-commit function alias
function gc
    $HOME/.local/bin/git-commit.fish $argv
end

# fish greeting
set fish_greeting ""

# set locale
set -x LC_ALL en_CA.UTF-8
set -x LANG en_CA.UTF-8

# style commands
set fish_color_command "#74c976" --bold
set fish_color_error "#cc6147" --bold
set fish_color_autosuggestion "#7b7c7b"
set fish_color_param "#a5c6f7"
set fish_color_operator "#a5c6f7"

starship init fish | source
fish_add_path $HOME/.local/bin
