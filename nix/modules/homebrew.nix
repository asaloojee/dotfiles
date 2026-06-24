{...}: {
  homebrew = {
    enable = true;
    brews = [
      "mas"
      "pi-coding-agent"
    ];

    # Ownership rule:
    # - Nix owns CLI/dev tooling and open fonts
    # - Homebrew owns GUI/macOS apps + proprietary font exceptions
    casks = [
      # GUI/macOS apps
      "adobe-creative-cloud"
      "blender"
      "claude"
      "discord"
      "docker-desktop"
      "figma"
      "alacritty"
      # "ollama"
      "obsidian"
      "handbrake-app"
      "helium-browser"
      "jordanbaird-ice"
      "karabiner-elements" # Needs stable paths for macOS permissions
      "keepingyouawake"
      "leader-key"
      "maccy"
      "mos"
      "proton-drive"
      "proton-mail"
      "proton-pass"
      "protonvpn"
      "sf-symbols"
      "slack"
      "tailscale-app"
      "zoom"

      # Font exceptions kept in Homebrew (not managed by nixpkgs)
      "font-martel"
      "font-playfair"
      "font-sf-mono"
      "font-sf-pro"
    ];

    masApps = {
      # "Yoink" = 457622435;
      # "PDFgear" = 6469021132;
    };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
