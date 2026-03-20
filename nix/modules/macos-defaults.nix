{...}: {
  system.defaults = {
    dock.autohide = true;
    dock.static-only = true;
    dock.tilesize = 16;
    finder.ShowPathbar = true;
    finder.NewWindowTarget = "Documents";
    menuExtraClock.ShowSeconds = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.GuestEnabled = false;
    NSGlobalDomain.AppleInterfaceStyle = "Dark";
    NSGlobalDomain.KeyRepeat = 2;
    finder.AppleShowAllExtensions = true;
    WindowManager.EnableStandardClickToShowDesktop = false;
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
  };

  services.sketchybar.enable = false;
  services.jankyborders.enable = false;
}
