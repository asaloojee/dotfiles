{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./home/fastfetch.nix
    ./home/gitui.nix
    ./home/pi-agent.nix
  ];
  home.username = "asaloojee";
  home.homeDirectory = "/Users/asaloojee";
  home.stateVersion = "24.11";
  xdg.enable = true;

  # Adopt new defaults for stateVersion > 24.11
  gtk.gtk4.theme = null;

  programs.home-manager.enable = true;

  # Disable Stylix for apps that manage their own theming
  stylix.targets.tmux.enable = false;
  stylix.targets.alacritty.enable = false;

  home.sessionVariables = {
    LC_ALL = "en_CA.UTF-8";
    LANG = "en_CA.UTF-8";
    EDITOR = "nvim";
    VISUAL = "nvim";
    NODE_ENV = "development";
    BUN_INSTALL = "$HOME/.bun";
    COMPOSER_PHAR_PATH = "/run/current-system/sw/bin/composer";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/google-cloud-sdk/bin"
    "$HOME/.bun/bin"
  ];

  programs = {
    aerospace = import ./home/aerospace.nix {inherit pkgs;};
    bat = import ./home/bat.nix {inherit pkgs;};
    eza = import ./home/eza.nix {inherit pkgs;};
    fzf = import ./home/fzf.nix {inherit pkgs;};
    alacritty = import ./home/alacritty.nix {inherit pkgs;};
    git = import ./home/git.nix {inherit pkgs;};
    tmux = import ./home/tmux.nix {inherit pkgs;};
    zoxide = import ./home/zoxide.nix {inherit pkgs;};
    starship = import ./home/starship.nix {inherit pkgs lib;};
    zsh = import ./home/zsh.nix {inherit config pkgs lib;};

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    delta = {
      enable = true;
      options = {
        syntax-theme = "base16-stylix";
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
    };
  };
}
