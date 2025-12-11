{ config, pkgs, ... }:

{
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # SketchyBar configuration
  programs.sketchybar = {
    enable = true;

    # Enable the launchd service to start sketchybar automatically
    service = {
      enable = true;
      errorLogFile = "/tmp/sketchybar.log";
      outLogFile = "/tmp/sketchybar.log";
    };

    # Use bash configuration (can switch to "lua" later if desired)
    configType = "bash";

    # Point to your dotfiles config directory
    # Using mkOutOfStoreSymlink so you can edit configs without rebuilding
    config = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/.config/sketchybar";
    };

    # Add any packages your sketchybar plugins might need
    extraPackages = with pkgs; [
      jq              # JSON parsing
      coreutils       # Date, stat, etc.
    ];
  };
}
