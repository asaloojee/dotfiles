{pkgs, ...}: {
  enable = true;

  settings = {
    env.TERM = "xterm-256color";

    font = {
      normal = {
        family = "JetBrainsMono Nerd Font";
        style = "Regular";
      };
      bold = {
        family = "JetBrainsMono Nerd Font";
        style = "Bold";
      };
      italic = {
        family = "JetBrainsMono Nerd Font";
        style = "Italic";
      };
      size = 18.0;
    };

    cursor = {
      style = {
        shape = "Block";
        blinking = "Off";
      };
      blink_interval = 0;
    };

    window = {
      padding = {
        x = 12;
        y = 12;
      };
      dynamic_padding = false;
      option_as_alt = "Both";
      decorations = "Buttonless";
      opacity = 0.9;
      blur = true;
    };

    mouse = {
      hide_when_typing = true;
    };

    terminal.shell = {
      program = "/bin/zsh";
      args = ["-l"];
    };

    # Theme import (Tokyo Night)
    general.import = ["${pkgs.alacritty-theme}/share/alacritty-theme/tokyo_night.toml"];
  };
}
