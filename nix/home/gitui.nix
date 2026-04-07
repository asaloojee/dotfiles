{...}: {
  xdg.configFile."gitui/theme.ron".text = ''
    (
      selected_tab: Some("Reset"),
      command_fg: Some("#A9B1D6"),
      selection_bg: Some("#2E3440"),
      selection_fg: Some("#A9B1D6"),
      cmdbar_bg: Some("#1A1B26"),
      cmdbar_extra_lines_bg: Some("#1A1B26"),
      disabled_fg: Some("#565F89"),
      diff_line_add: Some("#9ECE6A"),
      diff_line_delete: Some("#F7768E"),
      diff_file_added: Some("#9ECE6A"),
      diff_file_removed: Some("#F7768E"),
      diff_file_moved: Some("#E0AF68"),
      diff_file_modified: Some("#7AA2F7"),
      commit_hash: Some("#BB9AF7"),
      commit_time: Some("#565F89"),
      commit_author: Some("#7DCFFF"),
      danger_fg: Some("#F7768E"),
      push_gauge_bg: Some("#1A1B26"),
      push_gauge_fg: Some("#A9B1D6"),
      tag_fg: Some("#E0AF68"),
      branch_fg: Some("#BB9AF7"),
    )
  '';
}
