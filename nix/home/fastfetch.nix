{pkgs, ...}: let
  logo = import (
    if pkgs.stdenv.hostPlatform.isDarwin
    then ./fastfetch/macos.nix
    else ./fastfetch/nixos.nix
  );
in {
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": ${builtins.toJSON logo},
      "display": {
        "separator": "  "
      },
      "modules": [
        {
          "type": "title",
          "color": {
            "user": "green",
            "at": "white",
            "host": "cyan"
          }
        },
        {
          "type": "os",
          "key": "os"
        },
        {
          "type": "host",
          "key": "host"
        },
        {
          "type": "kernel",
          "key": "kernel"
        },
        {
          "type": "uptime",
          "key": "uptime"
        },
        {
          "type": "packages",
          "key": "packages"
        },
        {
          "type": "shell",
          "key": "shell"
        },
        {
          "type": "terminal",
          "key": "terminal"
        },
        {
          "type": "cpu",
          "key": "cpu"
        },
        {
          "type": "memory",
          "key": "memory"
        },
        {
          "type": "disk",
          "key": "disk /"
        },
        {
          "type": "break"
        },
        {
          "type": "colors"
        }
      ]
    }
  '';
}
