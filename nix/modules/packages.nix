{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.alejandra
    pkgs.ast-grep
    pkgs.biome
    pkgs.btop
    pkgs.bun
    pkgs.claude-code-bin
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
    pkgs.svelte-language-server
    pkgs.typescript
    pkgs.vue-language-server
    pkgs.vscode-langservers-extracted
    pkgs.vtsls

    pkgs.openssh
    pkgs.phpPackages.composer
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
