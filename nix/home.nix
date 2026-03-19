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

  programs = {
    zoxide = import ./home/zoxide.nix {inherit pkgs;};
    starship = import ./home/starship.nix {inherit pkgs lib;};
    zsh = import ./home/zsh.nix {inherit config pkgs lib;};
  };
}
