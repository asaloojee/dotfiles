{...}: {
  homebrew = {
    enable = true;
    brews = [
      "hunk"
      "mas"
      "mole"
      "openssl@4"
      "vite-plus"
    ];

    # Ownership rule:
    # - Nix owns CLI/dev tooling and open fonts, except Hunk (Homebrew)
    # - Homebrew owns GUI/macOS apps + proprietary font exceptions
    casks = [
      # GUI/macOS apps
      "adobe-creative-cloud"
      "blender"
      "brave-origin"
      "docker-desktop"
      "figma"
      "ghostty"
      "handbrake-app"
      "jordanbaird-ice"
      # "karabiner-elements" # Needs stable paths for macOS permissions
      "keepingyouawake"
      "mos"
      "obsidian"
      # "ollama"
      "proton-drive"
      "proton-mail"
      "proton-pass"
      "protonvpn"
      "raycast"
      "sf-symbols"
      "slack"
      "tailscale-app"

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
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };
}
