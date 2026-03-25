{pkgs, ...}: {
  enable = true;
  lfs.enable = true;

  settings = {
    user = {
      name = "asaloojee";
      email = "asaloojee@omniwerx.io";
    };
    init.defaultBranch = "main";
    pull.rebase = true;
    merge.conflictstyle = "zdiff3";
    alias = {
      s = "status";
      a = "add -A";
      c = "commit";
      cm = "commit -m";
      p = "push";
      lg = "log --oneline --graph --decorate -20";
    };
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
