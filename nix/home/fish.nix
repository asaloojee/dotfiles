{lib, ...}: {
  enable = true;

  shellAliases = {
    g = "gitui";
    ff = "fastfetch";
    mux = "tmuxinator";
    rebuild = "sudo -i darwin-rebuild switch --flake ~/dotfiles/nix#mac";
    n = "nvim";
    ga = "git add .";
  };

  shellAbbrs = {
    NE = {
      position = "anywhere";
      expansion = "2>/dev/null";
    };
    ND = {
      position = "anywhere";
      expansion = ">/dev/null";
    };
    NUL = {
      position = "anywhere";
      expansion = ">/dev/null 2>&1";
    };
    JQ = {
      position = "anywhere";
      expansion = "| jq";
    };
  };

  functions = {
    fish_greeting = "";
    fish_mode_prompt = "";

    copy_command_buffer = {
      description = "Copy the command line to the macOS clipboard";
      body = ''
        set --local buffer (commandline --current-buffer | string collect)
        printf %s "$buffer" | pbcopy
        commandline --function repaint
      '';
    };

    gp = {
      description = "Commit all changes and push";
      body = ''
        set --local message update
        if test (count $argv) -gt 0
          set message (string join " " -- $argv)
        end

        git add -A && git commit -m "$message" && git push
      '';
    };

    gr = {
      description = "Change to the current Git repository root";
      body = ''
        set --local root (command git rev-parse --show-toplevel 2>/dev/null)
        if test $status -ne 0
          echo "Not in a git repository"
          return 1
        end

        builtin cd "$root"
      '';
    };

    starship_transient_prompt_func = "starship module character";

    gc = {
      description = "Commit with message";
      body = ''
        if test (count $argv) -eq 0
             echo "Usage: gc <message>"
             return 1                                                                                                             end

           git commit -m (string join " " -- $argv)
      '';
    };
  };

  interactiveShellInit = lib.mkOrder 100 ''
    fish_vi_key_bindings

    set --global fish_cursor_default block
    set --global fish_cursor_insert block
    set --global fish_cursor_replace_one underscore
    set --global fish_cursor_visual block

    set --global fish_color_command 9ece6a
    set --global fish_color_param normal
    set --global fish_color_error f7768e --bold

    bind --mode insert \e\[3~ delete-char
    bind --mode insert \e\[H beginning-of-line
    bind --mode insert \e\[F end-of-line
    bind --mode insert \e\[A history-prefix-search-backward
    bind --mode insert \e\[B history-prefix-search-forward
    bind --mode insert \cx\ce edit_command_buffer
    bind --mode insert \cx\cc copy_command_buffer
  '';
}
