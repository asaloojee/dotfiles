{
  homeDirectory,
  pkgs,
  username,
  ...
}: {
  imports = [./hardware-configuration.nix];

  nixpkgs.hostPlatform = "aarch64-linux";
  networking.hostName = "dev";
  networking.useDHCP = true;
  networking.firewall.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_CA.UTF-8";

  users.users.${username} = {
    isNormalUser = true;
    home = homeDirectory;
    shell = pkgs.fish;
    extraGroups = ["wheel" "docker" "fido"];
  };

  # Allow this user to access Yubico FIDO devices without a desktop session.
  users.groups.fido = {};

  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ENV{ID_FIDO_TOKEN}=="1", ATTRS{idVendor}=="1050", GROUP="fido", MODE="0660"
  '';

  programs.fish.enable = true;

  # Support generic Linux executables downloaded by development tools.
  programs.nix-ld.enable = true;

  # Share a local SSH agent across login sessions for the USB-passed FIDO key.
  programs.ssh.startAgent = true;

  # SSH is handled by Tailscale, not sshd. Do not expose TCP 22 on the LAN.
  services.openssh = {
    enable = false;
    openFirewall = false;
  };
  services.tailscale = {
    enable = true;
    # Opens only Tailscale's UDP transport port, not SSH on TCP 22.
    openFirewall = true;
    extraSetFlags = ["--ssh" "--accept-dns=true"];
  };

  # Keep a local password for sudo and the UTM recovery console.
  security.sudo.wheelNeedsPassword = true;

  # Docker group membership is effectively root access; this is a personal dev VM.
  virtualisation.docker.enable = true;
  services.qemuGuest.enable = true;

  # Linux/VM-only tools. Cross-platform tools live in modules/packages.nix.
  environment.systemPackages = with pkgs; [
    cmake
    gcc
    gnumake
    hunk
    pkg-config
    tmux
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  system.stateVersion = "26.05";
}
