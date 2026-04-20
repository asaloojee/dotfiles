{pkgs, ...}: {
  # Ownership rule: nixpkgs is the default source for fonts.
  # Keep Homebrew font casks only for explicit exceptions.
  fonts.packages = [
    pkgs.fira
    pkgs.iosevka-comfy.comfy
    pkgs.iosevka-comfy.comfy-duo
    pkgs.maple-mono.NF-unhinted
    pkgs.maple-mono.truetype
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.iosevka
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.monaspace
    pkgs.noto-fonts
    pkgs.sketchybar-app-font
  ];
}
