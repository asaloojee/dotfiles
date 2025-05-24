{
  description = "Darwin system flake V1.2";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    alejandra.url = "github:kamadorueda/alejandra/4.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    alejandra,
    # ...
  }: let
    # add-unstable-packages = final: _prev: {
    # unstable = import inputs.nixpkgs-unstable {
    # system = "aarch64-darwin";
    # };
    # };
    # username = "asaloojee";
    configuration = {
      pkgs,
      config,
      ...
    }: {
      nixpkgs.config.allowUnfree = true;
      nix.settings.warn-dirty = false;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.alejandra
        pkgs.bat
        pkgs.discord
        pkgs.eza
        pkgs.firefox-devedition
        pkgs.fish
        pkgs.git
        pkgs.gitleaks
        pkgs.gitui
        pkgs.jetbrains.webstorm
        pkgs.mkalias
        pkgs.neofetch
        pkgs.neovim
        pkgs.obsidian
        pkgs.raycast
        pkgs.ripgrep
        pkgs.slack
        pkgs.spotify
        pkgs.stow
        pkgs.starship
        pkgs.tmux
        pkgs.tree
        pkgs.telegram-desktop
        pkgs.uutils-coreutils
        pkgs.yazi
        pkgs.zoxide
      ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
          "oh-my-posh"
          "eza"
        ];
        casks = [
          "zen"
          "signal"
          "figma"
          "proton-mail"
          "proton-drive"
          "protonvpn"
          "proton-pass"
          "zoom"
          "blender"
          "font-sf-pro"
          "sf-symbols"
          "font-hack-nerd-font"
          "ghostty"
        ];

        masApps = {
          "Yoink" = 457622435;
          "PDFgear" = 6469021132;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      services.sketchybar.enable = false;

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.nerd-fonts.meslo-lg
        pkgs.nerd-fonts.monaspace
        pkgs.nerd-fonts.iosevka
        pkgs.maple-mono.truetype
        pkgs.maple-mono.NF-unhinted
      ];

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

      system.primaryUser = "asaloojee";

      system.defaults = {
        dock.autohide = true;
        dock.static-only = true;
        dock.tilesize = 16;
        finder.ShowPathbar = true;
        finder.NewWindowTarget = "Documents";
        menuExtraClock.ShowSeconds = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.GuestEnabled = false;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        NSGlobalDomain.KeyRepeat = 2;
        finder.AppleShowAllExtensions = true;
        WindowManager.EnableStandardClickToShowDesktop = false;
        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
        NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
      };

      programs.zsh.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "asaloojee";
          };
        }
      ];
    };
  };
}
