{
  description = "Nix-Darwin Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    # Track Brew main because rolling cask definitions can require newer DSL features.
    nix-homebrew.inputs.brew-src.url = "github:Homebrew/brew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew,
    home-manager,
    ...
  }: let
    configurationName = "mac";
    homeDirectory = "/Users/${username}";
    hostName = "omnx-mac";
    platform = "aarch64-darwin";
    username = "asaloojee";
  in {
    formatter.${platform} = nixpkgs.legacyPackages.${platform}.alejandra;

    darwinConfigurations.${configurationName} = nix-darwin.lib.darwinSystem {
      specialArgs = {inherit homeDirectory hostName username;};
      modules = [
        ./modules/packages.nix
        ./modules/homebrew.nix
        ./modules/macos-defaults.nix
        ./modules/fonts.nix
        ./modules/sketchybar.nix
        ({pkgs, ...}: {
          nix = {
            gc = {
              automatic = true;
              interval = {
                Hour = 3;
                Minute = 15;
                Weekday = 7;
              };
              options = "--delete-older-than 30d";
            };
            optimise.automatic = true;
            registry.nixpkgs.flake = nixpkgs;
            settings = {
              experimental-features = "nix-command flakes";
              warn-dirty = false;
            };
          };
          networking = {
            computerName = hostName;
            hostName = hostName;
            localHostName = hostName;
          };
          nixpkgs.hostPlatform = platform;

          system.primaryUser = username;
          users.users.${username} = {
            name = username;
            home = homeDirectory;
            shell = pkgs.zsh;
          };

          programs.zsh.enable = true;
          security.pam.services.sudo_local.touchIdAuth = true;

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;
        })
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = username;
          };
        }
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = {inherit homeDirectory username;};
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ./home.nix;
          };
        }
      ];
    };
  };
}
