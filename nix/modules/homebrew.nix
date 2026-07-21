{...}: {
  homebrew = {
    enable = true;
    brews = [
      "hunk"
      "mas"
      "mole"
      "pi-coding-agent"
      "vite-plus"
    ];

    # Ownership rule:
    # - Nix owns CLI/dev tooling and open fonts
    # - Homebrew owns GUI/macOS apps + proprietary font exceptions
    casks = [
      # GUI/macOS apps
      "adobe-creative-cloud"
      "alacritty"
      "blender"
      "brave-origin"
      "chatgpt"
      "clickup"
      "discord"
      "docker-desktop"
      "figma"
      "handbrake-app"
      "jordanbaird-ice"
      "karabiner-elements" # Needs stable paths for macOS permissions
      "keepingyouawake"
      "leader-key"
      "maccy"
      "mos"
      "obsidian"
      # "ollama"
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

    onActivation = {
      cleanup = "none";
      extraFlags = [
        "--cleanup"
        "--zap"
      ];
    };
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
