{...}: {
  imports = [./hardware-configuration.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "dev";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  users.users.root.initialPassword = "root";

  system.stateVersion = "26.05";
}
