{
  pkgs,
  piNix,
  ...
}: {
  # Shared by the macOS workstation and the headless NixOS VM.
  environment.systemPackages = [
    # Terminal utilities, editor, and agent
    pkgs.btop
    pkgs.fastfetch
    pkgs.fd
    pkgs.jless
    pkgs.jq
    pkgs.just
    pkgs.neovim
    pkgs.openssh
    pkgs.ripgrep
    pkgs.stow
    pkgs.tree
    pkgs.superfile
    piNix.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Version control, secrets, and containers
    pkgs.doppler
    pkgs.gh
    pkgs.git-filter-repo
    pkgs.gitleaks
    pkgs.gnupg
    pkgs.lazydocker
    pkgs.yubikey-manager

    # Language runtimes and package managers (Rust is in rust.nix)
    pkgs.go
    pkgs.nodejs
    pkgs.phpPackages.composer
    pkgs.pnpm
    pkgs.python3
    pkgs.uv

    # Formatters, linters, parsers, and specialist CLI tools
    pkgs.alejandra
    pkgs.ast-grep
    pkgs.oxfmt
    pkgs.oxlint
    pkgs.potrace
    pkgs.prettier
    pkgs.ruff
    pkgs.shopify-cli
    pkgs.stylua
    pkgs.tree-sitter

    # LSP servers
    pkgs.astro-language-server
    pkgs.docker-compose-language-service
    pkgs.dockerfile-language-server
    pkgs.emmet-language-server
    pkgs.lua-language-server
    pkgs.nil
    pkgs.svelte-language-server
    pkgs.ty
    pkgs.typescript
    pkgs.vue-language-server
    pkgs.vscode-langservers-extracted
    pkgs.vtsls
    pkgs.yaml-language-server
  ];
}
