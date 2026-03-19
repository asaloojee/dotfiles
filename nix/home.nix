{
  config,
  pkgs,
  lib,
  ...
}: {
  home.username = "asaloojee";
  home.homeDirectory = "/Users/asaloojee";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.sessionVariables = {
    LC_ALL = "en_CA.UTF-8";
    LANG = "en_CA.UTF-8";
    EDITOR = "nvim";
    VISUAL = "nvim";
    NODE_ENV = "development";
    BUN_INSTALL = "$HOME/.bun";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/google-cloud-sdk/bin"
    "$HOME/.bun/bin"
  ];

  programs = {
    fzf = import ./home/fzf.nix {inherit pkgs;};
    git = import ./home/git.nix {inherit pkgs;};
    zoxide = import ./home/zoxide.nix {inherit pkgs;};
    starship = import ./home/starship.nix {inherit pkgs lib;};
    zsh = import ./home/zsh.nix {inherit config pkgs lib;};
  };
}
