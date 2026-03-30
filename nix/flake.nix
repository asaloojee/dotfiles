{
  description = "Nix-Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
    stylix,
    ...
  }: {
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;

    darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
      modules = [
        ./modules/packages.nix
        ./modules/homebrew.nix
        ./modules/macos-defaults.nix
        ./modules/fonts.nix
        ./modules/apps.nix
        ./modules/tailscale.nix
        ./modules/sketchybar.nix
        ./modules/stylix.nix
        ({pkgs, ...}: {
          nixpkgs.config.allowUnfree = true;
          nix.settings.warn-dirty = false;
          nix.settings.experimental-features = "nix-command flakes";
          nixpkgs.hostPlatform = "aarch64-darwin";

          system.primaryUser = "asaloojee";
          users.users.asaloojee = {
            name = "asaloojee";
            home = "/Users/asaloojee";
            shell = pkgs.zsh;
          };

          programs.zsh.enable = true;

          nix.optimise.automatic = true;

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;
        })
        stylix.darwinModules.stylix
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "asaloojee";
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.asaloojee = import ./home.nix;
        }
      ];
    };
  };
}
