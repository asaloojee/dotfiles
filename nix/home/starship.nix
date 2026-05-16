{
  pkgs,
  lib,
  ...
}: {
  enable = true;
  enableZshIntegration = true;
  settings = {
    format = lib.concatStrings [
      "$username"
      "$hostname"
      "$directory"
      "$git_branch"
      "$git_state"
      "$git_status"
      "$git_metrics"
      "$fill"
      "$nodejs"
      "$cmd_duration $jobs $time"
      "$line_break"
      "$character"
    ];

    fill.symbol = " ";

    directory = {
      style = "blue";
      read_only = " 󱌃";
      home_symbol = "󰜥 ";
      truncation_length = 4;
      truncate_to_repo = false;
      truncation_symbol = ".../";
    };

    character = {
      format = "$symbol ";
      success_symbol = "[❯](magenta)";
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
      symbol = " ";
      format = "[$symbol($version )]($style)";
      style = "green";
      detect_extensions = [];
      detect_files = ["pnpm-lock.yaml" "package-lock.json" "yarn.lock"];
      detect_folders = [];
    };

    python = {
      symbol = " ";
      format = "[$symbol($version )]($style)";
      style = "yellow";
    };
  };
}
