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
      "$bun"
      "$nodejs"
      "$cmd_duration $jobs $time"
      "$line_break"
      "$character"
    ];

    fill.symbol = " ";

    directory = {
      style = "#7aa2f7";
      read_only = " 󱌃";
      home_symbol = "󰜥 ";
      truncation_length = 4;
      truncate_to_repo = false;
      truncation_symbol = ".../";
    };

    character = {
      format = "$symbol ";
      success_symbol = "[❯](#bb9af7)";
      error_symbol = "[❯](#f7768e)";
    };

    git_branch = {
      symbol = "󰘬 ";
      format = "[$symbol$branch]($style) ";
      style = "#565f89";
    };

    jobs = {
      symbol = "󰒓 ";
      style = "bold #f7768e";
      number_threshold = 1;
      format = "[$symbol]($style)";
    };

    git_status = {
      format = "([\\[$all_status$ahead_behind\\]]($style) )";
      style = "#565f89";
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
      style = "#565f89";
    };

    git_metrics = {
      disabled = false;
      added_style = "#9ece6a";
      deleted_style = "#f7768e";
    };

    cmd_duration = {
      format = "[$duration]($style)";
      style = "#e0af68";
    };

    memory_usage.symbol = "󰍛 ";

    bun = {
      symbol = " ";
      format = "[$symbol($version )]($style)";
      style = "#f7768e";
      detect_extensions = [];
      detect_files = ["bun.lock"];
      detect_folders = [];
    };

    nodejs = {
      symbol = " ";
      format = "[$symbol($version )]($style)";
      style = "#9ece6a";
      detect_extensions = [];
      detect_files = ["package-lock.json" "yarn.lock"];
      detect_folders = [];
    };

    python = {
      symbol = " ";
      format = "[$symbol($version )]($style)";
      style = "#e0af68";
    };
  };
}
