set -gx PATH $PATH /run/current-system/sw/bin
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

# nix path?
set -gx PATH $PATH /nix/var/nix/profiles/default/bin/

function fish_command_not_found
    echo -e "\033[31mCommand not found: $argv\033[0m"
end

# yazi setup
export EDITOR="nvim"

starship init fish | source
