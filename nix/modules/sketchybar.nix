{pkgs, ...}: let
  sbarlua = pkgs.callPackage ../packages/sbarlua.nix {};
  sketchybarConfigDir = "/Users/asaloojee/.config/sketchybar";
in {
  services.sketchybar = {
    enable = true;
    extraPackages = [pkgs.aerospace pkgs.sketchybar-app-font];
    config = ''
      #!${pkgs.bash}/bin/bash
      export SBARLUA_CPATH="${sbarlua}/lib/lua/?.so"
      export SBAR_CONFIG_DIR="${sketchybarConfigDir}"
      exec ${sbarlua}/bin/lua "${sketchybarConfigDir}/sketchybarrc.lua"
    '';
  };

  services.jankyborders = {
    enable = true;
    width = 2.0;
    style = "round";
    order = "below";
    hidpi = true;
    active_color = "0xfff5f5f5";
    inactive_color = "0x00000000";
  };
}
