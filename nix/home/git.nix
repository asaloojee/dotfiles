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
