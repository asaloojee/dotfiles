{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.aerospace
    pkgs.alejandra
    pkgs.ast-grep
    pkgs.btop
    pkgs.bun
    pkgs.claude-code-bin
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
    pkgs.neovim

    # LSP servers
    pkgs.vtsls
    pkgs.typescript
    pkgs.vscode-langservers-extracted
    pkgs.astro-language-server

    pkgs.openssh
    pkgs.phpPackages.composer
    pkgs.prettier
    pkgs.ruff
    pkgs.ripgrep
    pkgs.rust-analyzer
    pkgs.rustfmt
    pkgs.rustup
    pkgs.stylua
    pkgs.stow
    pkgs.tailscale
    pkgs.tmuxinator
    pkgs.tree
    pkgs.tree-sitter
    pkgs.uv
    pkgs.yubikey-manager
  ];
}
