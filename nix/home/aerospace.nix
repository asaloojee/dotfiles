{pkgs, ...}: {
  enable = true;
  launchd.enable = true;
  settings = {
    after-login-command = [];
    after-startup-command = [];
    exec-on-workspace-change = [
      "/bin/bash"
      "-c"
      # "sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
    ];

    start-at-login = true;

    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    accordion-padding = 20;
    default-root-container-layout = "accordion";
    default-root-container-orientation = "auto";

    key-mapping.preset = "qwerty";

    gaps = {
      inner.horizontal = 4;
      inner.vertical = 4;
      outer.left = 4;
      outer.bottom = 4;
      outer.top = 4;
      outer.right = 4;
    };

    mode.main.binding = {
      ctrl-alt-cmd-slash = "layout tiles horizontal vertical";
      ctrl-alt-cmd-comma = "layout accordion horizontal vertical";

      ctrl-alt-cmd-h = "focus left";
      ctrl-alt-cmd-j = "focus down";
      ctrl-alt-cmd-k = "focus up";
      ctrl-alt-cmd-l = "focus right";

      ctrl-alt-cmd-shift-h = "move left";
      ctrl-alt-cmd-shift-j = "move down";
      ctrl-alt-cmd-shift-k = "move up";
      ctrl-alt-cmd-shift-l = "move right";

      ctrl-alt-cmd-shift-minus = "resize smart -50";
      ctrl-alt-cmd-shift-equal = "resize smart +50";

      ctrl-alt-cmd-1 = "workspace 1";
      ctrl-alt-cmd-2 = "workspace 2";
      ctrl-alt-cmd-3 = "workspace 3";
      ctrl-alt-cmd-4 = "workspace 4";
      ctrl-alt-cmd-5 = "workspace 5";

      ctrl-alt-cmd-shift-1 = "move-node-to-workspace 1";
      ctrl-alt-cmd-shift-2 = "move-node-to-workspace 2";
      ctrl-alt-cmd-shift-3 = "move-node-to-workspace 3";
      ctrl-alt-cmd-shift-4 = "move-node-to-workspace 4";
      ctrl-alt-cmd-shift-5 = "move-node-to-workspace 5";

      ctrl-alt-cmd-f = "fullscreen";
      ctrl-alt-cmd-tab = "workspace-back-and-forth";
      ctrl-alt-cmd-shift-tab = "move-workspace-to-monitor --wrap-around next";

      ctrl-alt-cmd-shift-semicolon = "mode service";
    };

    mode.service.binding = {
      esc = ["reload-config" "mode main"];
      r = ["flatten-workspace-tree" "mode main"];
      f = ["layout floating tiling" "mode main"];
      backspace = ["close-all-windows-but-current" "mode main"];

      alt-shift-h = ["join-with left" "mode service"];
      alt-shift-j = ["join-with down" "mode service"];
      alt-shift-k = ["join-with up" "mode service"];
      alt-shift-l = ["join-with right" "mode service"];
    };

    on-window-detected = [
      {
        "if".app-id = "com.figma.Desktop";
        run = "move-node-to-workspace 3";
      }
      {
        "if".app-id = "com.apple.Music";
        run = ["move-node-to-workspace 5"];
      }
      {
        "if".app-id = "com.brave.Browser";
        "if".window-title-regex-substring = "DevTools";
        run = "layout floating";
      }
      {
        "if".app-id = "com.brave.Browser";
        run = "move-node-to-workspace 1";
      }
      {
        "if".app-id = "com.tinyspeck.slackmacgap";
        run = "move-node-to-workspace 4";
      }
      {
        "if".app-id = "com.apple.finder";
        run = "layout floating";
      }
      {
        "if".app-id = "com.apple.messages";
        run = "layout floating";
      }
      {
        "if".app-id = "ch.protonvpn.mac";
        run = "layout floating";
      }
      {
        "if".app-id = "com.apple.Safari";
        run = "move-node-to-workspace 2";
      }
      {
        "if".app-id = "com.todesktop.230313mzl4w4u92";
        run = "move-node-to-workspace 2";
      }
      {
        "if".app-id = "ch.protonmail.desktop";
        run = "move-node-to-workspace 1";
      }
      {
        "if".app-id = "com.tinyspeck.slackmacgap";
        run = "layout floating";
      }
    ];
  };
}
