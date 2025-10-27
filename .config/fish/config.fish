# Fish greeting
set fish_greeting ""

# Locale settings
set -gx LC_ALL en_CA.UTF-8
set -gx LANG en_CA.UTF-8

# Editor
set -gx EDITOR nvim

# Starship configuration
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

# PATH management - fish_add_path handles duplicates automatically
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path $HOME/google-cloud-sdk/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /nix/var/nix/profiles/default/bin
fish_add_path /run/current-system/sw/bin

# Aliases
alias ls="eza --icons=always"
alias g="gitui"
alias mux="tmuxinator"
alias rebuild="sudo darwin-rebuild switch --flake ~/dotfiles/nix#mac"

# Yazi file manager with directory changing
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Interactive directory navigation with lstr
function lcd
    set -l selected_dir (lstr interactive -g --icons)
    if test -n "$selected_dir" -a -d "$selected_dir"
        cd "$selected_dir"
    end
end

# Git commit helper
function gc
    $HOME/.local/bin/git-commit.fish $argv
end

# Zoxide (smarter cd)
zoxide init fish | source
alias cd="z"

# Initialize Starship prompt
starship init fish | source
