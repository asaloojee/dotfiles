{
  pkgs,
  piNix,
  ...
}: {
  environment.systemPackages = [
    pkgs.alejandra
    pkgs.ast-grep
    pkgs.btop
    pkgs.doppler
    pkgs.fastfetch
    pkgs.fd
    pkgs.gh
    pkgs.git-filter-repo
    pkgs.gitleaks
    pkgs.gnupg
    pkgs.go

    pkgs.jless
    pkgs.jq
    pkgs.just
    pkgs.lazydocker
    pkgs.neovim
    piNix.packages.${pkgs.stdenv.hostPlatform.system}.default

    pkgs.openssh
    pkgs.oxfmt
    pkgs.oxlint
    pkgs.pnpm
    pkgs.potrace
    pkgs.prettier
    pkgs.phpPackages.composer
    pkgs.ruff
    pkgs.ripgrep
    pkgs.shopify-cli
    pkgs.stylua
    pkgs.stow
    pkgs.tree
    pkgs.tree-sitter
    pkgs.uv
    pkgs.yazi
    pkgs.yubikey-manager

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
