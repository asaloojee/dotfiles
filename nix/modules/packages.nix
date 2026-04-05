{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.aerospace
    pkgs.alejandra
    pkgs.ast-grep
    pkgs.btop
    pkgs.bun
    pkgs.claude-code
    pkgs.doppler
    pkgs.fastfetch
    pkgs.fd
    pkgs.gh
    pkgs.git-filter-repo
    pkgs.gitleaks
    pkgs.gitui
    pkgs.gnupg
    pkgs.go

    pkgs.ice-bar
    pkgs.jless
    pkgs.jq
    pkgs.just
    pkgs.lazydocker
    pkgs.mkalias

    pkgs.phpPackages.composer
    pkgs.ripgrep
    pkgs.rust-analyzer
    pkgs.rustup
    pkgs.stow
    pkgs.tailscale
    pkgs.tmuxinator
    pkgs.tree
    pkgs.tree-sitter
    pkgs.uv

    # Language servers (for Helix)
    pkgs.typescript
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted # CSS, HTML, JSON, ESLint
    pkgs.yaml-language-server
    pkgs.bash-language-server
    pkgs.astro-language-server
    pkgs.marksman
    pkgs.taplo

    # Formatters
    pkgs.prettier
    pkgs.ruff
  ];
}
