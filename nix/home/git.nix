{pkgs, ...}: {
  enable = true;
  lfs.enable = true;

  userName = "asaloojee";
  userEmail = "asaloojee@omniwerx.io";

  extraConfig = {
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
