{pkgs, ...}: {
  # Ownership rule: nixpkgs is the default source for fonts.
  # Keep Homebrew font casks only for explicit exceptions.
  fonts.packages = [
    # pkgs.iosevka-comfy.comfy
    # pkgs.iosevka-comfy.comfy-duo
    pkgs.maple-mono.NF-unhinted
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.meslo-lg
    # pkgs.sketchybar-app-font
  ];
}
