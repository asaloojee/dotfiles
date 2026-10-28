{pkgs, ...}: {
  enable = true;
  package = pkgs.jujutsu;

  settings = {
    user = {
      name = "asaloojee";
      email = "asaloojee@omniwerx.io";
    };

    experimental-advance-branches.enabled-branches = ["main"];

    aliases.ship = ["util" "exec" "--" "sh" "-c" "jj git fetch && jj git push -b main"];

    git.colocate = true;
    ui = {
      editor = "nvim";
      pager = ["hunk" "pager"];
      diff-formatter = ":git";
    };

    "--scope" = [
      {
        "--when".repositories = ["~/dev/pre-script"];
        user = {
          name = "a-saloojee-ps";
          email = "asaloojee@pre-script.com";
        };
      }
    ];
  };
}
