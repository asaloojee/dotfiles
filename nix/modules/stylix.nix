{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";

    # Tokyo Night Terminal Dark has correct base16 slot mappings for terminal colors.
    # Overrides fix the green (base0B: teal→green) and foreground (base05: dim→proper).
    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-terminal-dark.yaml";
    override = {
      base0B = "9ECE6A"; # Proper Tokyo Night green (replaces teal #41A6B5)
      base05 = "A9B1D6"; # Proper foreground (replaces dim #787C99)
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 13.5; # Stylix scales by 4/3 on macOS → 18pt in Ghostty
      };
    };

    opacity.terminal = 0.90;
  };
}
