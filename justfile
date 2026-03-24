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

# Collect nix garbage (old generations + store)
gc:
    sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
    sudo nix-collect-garbage -d

# Show generations history
generations:
    darwin-rebuild --list-generations
