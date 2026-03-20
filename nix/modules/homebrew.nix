{...}: {
  homebrew = {
    enable = true;
    taps = [];

    brews = [
      "mas"
      "tailscale"
    ];

    casks = [
      "adobe-creative-cloud"
      "brave-browser"
      "claude"
      "discord"
      "docker-desktop"
      "figma"
      "font-hack-nerd-font"
      "font-martel"
      "font-playfair"
      "font-sf-mono"
      "font-sf-pro"
      "ghostty"
      # "ollama"
      "obsidian"
      "handbrake-app"
      "karabiner-elements" # Needs stable paths for macOS permissions
      "leader-key"
      "maccy"
      "mos"
      "proton-drive"
      "proton-mail"
      "proton-pass"
      "protonvpn"
      "sf-symbols"
      "slack"
      "zoom"
    ];

    masApps = {
      # "Yoink" = 457622435;
      "PDFgear" = 6469021132;
    };

    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };
}
