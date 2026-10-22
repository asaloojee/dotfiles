{...}: {
  homebrew = {
    enable = true;
    taps = ["anomalyco/tap"];
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
      "anomalyco/tap/hex"
      "blender"
      "brave-origin@nightly"
      "docker-desktop"
      "figma"
      "ghostty"
      "handbrake-app"
      "jordanbaird-ice"
      # "karabiner-elements" # Needs stable paths for macOS permissions
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
      "status-trio"
      "tailscale-app"

      # Font exceptions kept in Homebrew (not managed by nixpkgs)
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
