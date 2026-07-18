# Dotfiles management commands
# Run `just` or `just --list` to see available recipes

# List all recipes
default:
    @just --list

# Rebuild the system (nix-darwin + home-manager)
rebuild:
    sudo -i darwin-rebuild switch --flake ~/dotfiles/nix#mac

# Symlink stow-managed configs into ~/.config
stow:
    stow --target "$HOME/.config" .config

# Format managed source files
fmt:
    alejandra nix/flake.nix nix/home.nix nix/home/*.nix nix/modules/*.nix nix/packages/*.nix
    stylua .config/nvim .config/sketchybar
    oxfmt .pi/agent/AGENTS.md .pi/agent/extensions/safety-gate.ts .pi/agent/settings.json

# Check formatting, JSON syntax, and tracked secrets
check:
    alejandra --check nix/flake.nix nix/home.nix nix/home/*.nix nix/modules/*.nix nix/packages/*.nix
    stylua --check .config/nvim .config/sketchybar
    oxfmt --check .pi/agent/AGENTS.md .pi/agent/extensions/safety-gate.ts .pi/agent/settings.json
    git ls-files -z '*.json' | xargs -0 -n 1 sh -c 'test ! -e "$1" || jq empty "$1"' _
    gitleaks git --redact --no-banner .

# Update flake inputs
update:
    cd nix && nix flake update

# Rollback to previous nix-darwin generation
rollback:
    sudo darwin-rebuild switch --rollback

# Show current flake inputs and their revisions
flake-info:
    nix flake metadata ~/dotfiles/nix

# Diff current config against what's deployed
diff:
    darwin-rebuild build --flake ~/dotfiles/nix#mac && nix store diff-closures /nix/var/nix/profiles/system ./result && rm result

# Garbage collect old generations and nix store
gc:
    sudo -i nix-env --delete-generations old --profile /nix/var/nix/profiles/system
    sudo -i nix-collect-garbage -d
    sudo -i nix store gc

# Delete old system profile generations only
delete-old:
    sudo -i nix-env --delete-generations old --profile /nix/var/nix/profiles/system

# Run nix-collect-garbage only
collect-garbage:
    sudo -i nix-collect-garbage -d

# Show generations history
generations:
    darwin-rebuild --list-generations
