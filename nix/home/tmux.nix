{pkgs, ...}: {
  enable = true;
  baseIndex = 1;
  keyMode = "vi";
  mouse = true;
  shortcut = "Space";
  terminal = "xterm-256color";
  shell = "${pkgs.zsh}/bin/zsh";

  plugins = with pkgs.tmuxPlugins; [
    sensible
    vim-tmux-navigator
    {
      plugin = tokyo-night-tmux;
      extraConfig = ''
        set -g @tokyo-night-tmux_show_datetime 0
        set -g @tokyo-night-tmux_show_path 0
        set -g @tokyo-night-tmux_path_format relative
        set -g @tokyo-night-tmux_window_id_style digital
        set -g @tokyo-night-tmux_show_git 0
      '';
    }
    yank
  ];

  extraConfig = ''
    # Terminal overrides
    set-option -sa terminal-overrides ",xterm*:Tc"

    # Pane base index
    set -g pane-base-index 1
    set-option -g renumber-windows on

    # Vim style pane selection
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # Clear screen (since l is taken)
    bind L send-keys '^L'

    # Alt-arrow to switch panes (no prefix)
    bind -n M-Left select-pane -L
    bind -n M-Right select-pane -R
    bind -n M-Up select-pane -U
    bind -n M-Down select-pane -D

    # Shift arrow to switch windows
    bind -n S-Left  previous-window
    bind -n S-Right next-window

    # Shift Alt vim keys to switch windows
    bind -n M-H previous-window
    bind -n M-L next-window

    # Vi copy mode
    bind-key -T copy-mode-vi v send-keys -X begin-selection
    bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
    bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

    # Open splits/windows in current path
    bind '"' split-window -v -c "#{pane_current_path}"
    bind % split-window -h -c "#{pane_current_path}"
    bind c new-window -c "#{pane_current_path}"

    # Resize panes (fine)
    bind -r Up resize-pane -U 1
    bind -r Down resize-pane -D 1
    bind -r Left resize-pane -L 1
    bind -r Right resize-pane -R 1

    # Resize panes (coarse)
    bind -r S-Up resize-pane -U 5
    bind -r S-Down resize-pane -D 5
    bind -r S-Left resize-pane -L 5
    bind -r S-Right resize-pane -R 5

    # Custom status bar
    set -g status-right "#[fg=blue,bold]#(echo '#{pane_current_path}' | sed 's|^$HOME|~|' | awk -F/ '{print $1\"/\"$2\"/\"$3}') "
  '';
}
