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
    stow .

# Install utility scripts to ~/.local/bin
install-scripts force="":
    ./scripts/install.sh {{ if force == "force" { "--force" } else { "" } }}

# Format all nix files
fmt:
    alejandra nix/flake.nix nix/home.nix nix/home/*.nix nix/modules/*.nix

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
