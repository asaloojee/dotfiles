{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.alejandra
    pkgs.ast-grep
    pkgs.btop
    pkgs.pnpm
    pkgs.dioxus-cli
    pkgs.doppler
    pkgs.fastfetch
    pkgs.fd
    pkgs.gh
    pkgs.git-filter-repo
    pkgs.gitleaks
    pkgs.gitui
    pkgs.gnupg
    pkgs.go

    pkgs.jless
    pkgs.jq
    pkgs.just
    pkgs.lazydocker
    pkgs.neovim

    # LSP servers
    pkgs.astro-language-server
    pkgs.docker-compose-language-service
    pkgs.dockerfile-language-server
    pkgs.svelte-language-server
    pkgs.typescript
    pkgs.vue-language-server
    pkgs.vscode-langservers-extracted
    pkgs.vtsls
    pkgs.yaml-language-server

    pkgs.openssh
    pkgs.oxfmt
    pkgs.oxlint
    pkgs.potrace
    pkgs.prettier
    pkgs.phpPackages.composer
    pkgs.ruff
    pkgs.ripgrep
    pkgs.rust-analyzer
    pkgs.rustfmt
    pkgs.rustup
    pkgs.stylua
    pkgs.stow
    pkgs.tmuxinator
    pkgs.tree
    pkgs.tree-sitter
    pkgs.uv
    pkgs.yubikey-manager
  ];
}
