{pkgs, ...}: {
  enable = true;
  package = null;

  enableFishIntegration = true;
  shellWrapperName = "y";

  flavors.tokyo-night = pkgs.fetchFromGitHub {
    owner = "BennyOe";
    repo = "tokyo-night.yazi";
    rev = "8e6296f14daff24151c736ebd0b9b6cd89b02b03";
    hash = "sha256-LArhRteD7OQRBguV1n13gb5jkl90sOxShkDzgEf3PA0=";
  };

  theme.flavor = {
    dark = "tokyo-night";
    light = "tokyo-night";
  };

  plugins = {
    git = {
      package = pkgs.yaziPlugins.git;
      setup = true;
      settings.order = 1500;
    };
  };

  settings = {
    mgr.ratio = [1 1 1];
    plugin.prepend_fetchers = [
      {
        url = "*";
        run = "git";
        group = "git";
      }
      {
        url = "*/";
        run = "git";
        group = "git";
      }
    ];
  };

  keymap.mgr.prepend_keymap = [
    {
      on = "h";
      run = "leave";
      desc = "Go to parent directory";
    }
    {
      on = "j";
      run = "arrow 1";
      desc = "Move down";
    }
    {
      on = "k";
      run = "arrow -1";
      desc = "Move up";
    }
    {
      on = "l";
      run = "enter";
      desc = "Open file or enter directory";
    }
  ];
}
