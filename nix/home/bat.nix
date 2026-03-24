{pkgs, ...}: {
  enable = true;
  config = {
    theme = "tokyonight_night";
  };
  themes = {
    tokyonight_night = {
      src = pkgs.fetchFromGitHub {
        owner = "folke";
        repo = "tokyonight.nvim";
        rev = "v4.14.1";
        hash = "sha256-kQsV0x8/ycFp3+S6YKyiKFsAG5taOdQmx/dMuDqGyEQ=";
      };
      file = "extras/sublime/tokyonight_night.tmTheme";
    };
  };
}
