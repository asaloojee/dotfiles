{pkgs, ...}: {
  enable = true;
  package = pkgs.jujutsu;

  settings = {
    user = {
      name = "asaloojee";
      email = "asaloojee@omniwerx.io";
    };

    git.colocate = true;
    ui.editor = "nvim";

    "--scope" = [
      {
        "--when".repositories = ["~/dev/pre-script"];
        user = {
          name = "a-saloojee-ps";
          email = "asaloojee@pre-script.com";
        };
      }
      {
        "--when".commands = ["diff" "show"];
        ui = {
          diff-formatter = ":git";
          pager = [
            "${pkgs.delta}/bin/delta"
            "--line-numbers"
            "--navigate"
            "--side-by-side"
          ];
        };
      }
    ];
  };
}
