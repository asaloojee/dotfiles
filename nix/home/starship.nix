{
  pkgs,
  lib,
  ...
}: {
  enable = true;
  enableFishIntegration = true;
  enableTransience = true;
  settings = {
    format = lib.concatStrings [
      "$username"
      "$hostname"
      "$directory"
      "\${custom.jj}"
      "\${custom.jj_added}"
      "\${custom.jj_removed}"
      "\${custom.git_branch}"
      "\${custom.git_state}"
      "\${custom.git_status}"
      "\${custom.git_metrics}"
      "$fill"
      "$nodejs"
      "$cmd_duration $jobs $time"
      "$line_break"
      "$character"
    ];

    # Keep the existing Git modules, but only render them outside jj workspaces.
    custom =
      lib.genAttrs ["git_branch" "git_state" "git_status" "git_metrics"] (module: {
        command = "${pkgs.starship}/bin/starship module ${module}";
        when = "! ${pkgs.jujutsu}/bin/jj root --ignore-working-copy >/dev/null 2>&1";
        shell = ["${pkgs.bash}/bin/bash" "--noprofile" "--norc"];
        format = "$output";
        # Preserve the built-in modules' ANSI colors.
        unsafe_no_escape = true;
      })
      // lib.genAttrs ["jj_added" "jj_removed"] (module: let
        added = module == "jj_added";
        metric =
          if added
          then "total_added"
          else "total_removed";
      in {
        description = "Jujutsu lines ${
          if added
          then "added"
          else "removed"
        }";
        when = "${pkgs.jujutsu}/bin/jj root --ignore-working-copy >/dev/null 2>&1";
        shell = ["${pkgs.bash}/bin/bash" "--noprofile" "--norc"];
        command = ''
          ${pkgs.jujutsu}/bin/jj log --no-graph --color=never -r @ -T '
            if(diff.stat().${metric}() > 0, diff.stat().${metric}())
          '
        '';
        style =
          if added
          then "green"
          else "red";
        format = "[${
          if added
          then "+"
          else "-"
        }$output]($style) ";
      })
      // {
        jj = {
          description = "Jujutsu change, bookmarks, and working-copy status";
          when = "${pkgs.jujutsu}/bin/jj root --ignore-working-copy >/dev/null 2>&1";
          shell = ["${pkgs.bash}/bin/bash" "--noprofile" "--norc"];
          command = ''
            ${pkgs.jujutsu}/bin/jj log --no-graph --color=never -r @ -T '
              separate(" ",
                change_id.shortest(8),
                bookmarks,
                if(conflict, "[󰅖]"),
                if(!empty, "[!]"),
                if(empty, "[∅]")
              )
            '
          '';
          symbol = "󰘬 ";
          style = "bright-black";
          format = "[$symbol$output]($style) ";
        };
      };

    fill.symbol = " ";

    directory = {
      style = "blue";
      read_only = " 󱌃";
      home_symbol = "~";
      truncation_length = 4;
      truncate_to_repo = false;
      truncation_symbol = ".../";
    };

    character = {
      format = "$symbol ";
      success_symbol = "[❯](#bb9af7)";
      error_symbol = "[❯](red)";
    };

    git_branch = {
      symbol = "󰘬 ";
      format = "[$symbol$branch]($style) ";
      style = "bright-black";
    };

    jobs = {
      symbol = "󰒓 ";
      style = "bold red";
      number_threshold = 1;
      format = "[$symbol]($style)";
    };

    git_status = {
      format = "([\\[$all_status$ahead_behind\\]]($style) )";
      style = "bright-black";
      ahead = "󰁝";
      behind = "󰁅";
      diverged = "󰹹";
      conflicted = "󰅖";
      deleted = "󰍴";
      renamed = "󰄾";
      modified = "!";
      staged = "+";
      untracked = "?";
      stashed = "";
    };

    git_state = {
      format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
      style = "bright-black";
    };

    git_metrics = {
      disabled = false;
      added_style = "green";
      deleted_style = "red";
    };

    cmd_duration = {
      format = "[$duration]($style)";
      style = "yellow";
    };

    memory_usage.symbol = "󰍛 ";

    nodejs = {
      symbol = " ";
      format = "[$symbol($version )]($style)";
      style = "green";
      detect_extensions = [];
      detect_files = ["pnpm-lock.yaml" "package-lock.json" "yarn.lock"];
      detect_folders = [];
    };

    python = {
      symbol = " ";
      format = "[$symbol($version )]($style)";
      style = "yellow";
    };
  };
}
