{config, ...}: let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  liveLink = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in {
  home.file = {
    ".pi/agent/settings.json" = {
      source = liveLink ".pi/agent/settings.json";
      force = true;
    };
    ".pi/agent/AGENTS.md" = {
      source = liveLink ".pi/agent/AGENTS.md";
      force = true;
    };
    ".pi/agent/extensions" = {
      source = liveLink ".pi/agent/extensions";
      force = true;
    };
    ".pi/agent/skills" = {
      source = liveLink ".pi/agent/skills";
      force = true;
    };
    ".local/bin/hypa" = {
      executable = true;
      text = ''
        #!/usr/bin/env sh
        set -eu
        exec "$HOME/.pi/agent/npm/node_modules/.bin/hypa" "$@"
      '';
    };
  };
}
