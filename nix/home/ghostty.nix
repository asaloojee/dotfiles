{pkgs, ...}: {
  enable = true;
  enableZshIntegration = true;
  package = null; # Installed via Homebrew cask, not nixpkgs (Linux-only)

  # Stylix auto-sets: theme (colors), font-family, font-size, background-opacity
  settings = {
    font-style = "Regular";
    font-feature = ["-calt" "-dlig" "-liga"];
    cursor-style = "block";
    cursor-style-blink = false;
    window-title-font-family = "JetBrainsMono Nerd Font";

    background-blur = true;

    macos-titlebar-style = "tabs";
    macos-titlebar-proxy-icon = "hidden";

    shell-integration = "zsh";
    shell-integration-features = "no-cursor";

    window-padding-x = 12;
    window-padding-y = 0;
    macos-window-shadow = false;
    mouse-hide-while-typing = true;
    macos-secure-input-indication = true;
    macos-auto-secure-input = true;
  };
}
