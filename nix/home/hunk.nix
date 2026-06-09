{...}: {
  xdg.configFile."hunk/config.toml".text = ''
    theme = "catppuccin-mocha"
    mode = "auto"
    line_numbers = true
    wrap_lines = false
  '';
}
