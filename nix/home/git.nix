{pkgs, ...}: {
  enable = true;
  lfs.enable = true;
  signing.format = null;
  ignores = [
    ".pi-lens/"
  ];

  settings = {
    user = {
      name = "asaloojee";
      email = "asaloojee@omniwerx.io";
    };
    init.defaultBranch = "main";
    pull.rebase = true;
    merge.conflictstyle = "zdiff3";
    diff.colorMoved = "default";
  };

  includes = [
    {
      condition = "gitdir:~/dev/pre-script/";
      contents = {
        user = {
          name = "a-saloojee-ps";
          email = "asaloojee@pre-script.com";
        };
      };
    }
  ];
}
