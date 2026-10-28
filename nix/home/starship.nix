{
  pkgs,
  lib,
  ...
}: let
  # Generated from themes/tokyonight-night.oklch.json; shared with Neovim and Rex.
  colors = builtins.fromJSON (builtins.readFile ../../.config/nvim/tokyonight-night.json);
in {
  enable = true;
  enableFishIntegration = true;
  enableTransience = true;
  settings = {
    palette = "tokyonight_night";
    palettes.tokyonight_night = {
      inherit (colors) blue purple red yellow;
      gray = colors.dark5;
    };

    format = lib.concatStrings [
      "$username"
      "$hostname"
      "$directory"
      "\${custom.vcs}"
      "$fill"
      "$cmd_duration"
      "$line_break"
      "$character"
    ];

    custom.vcs = {
      description = "Minimal jj change state or Git branch and status";
      command = lib.getExe (pkgs.writeShellApplication {
        name = "starship-vcs";
        runtimeInputs = [pkgs.git pkgs.jujutsu];
        # Status probes legitimately return nonzero for absent refs/markers.
        bashOptions = [];
        text = ''
          export LC_ALL=C
          export GIT_OPTIONAL_LOCKS=0

          branch=
          dirty=
          conflict=
          ahead=
          behind=

          if jj root --ignore-working-copy >/dev/null 2>&1; then
            # Snapshot once so non-empty and conflict markers reflect current files.
            state=$(jj log --no-graph --color=never -r @ -T \
              'change_id.shortest(8) ++ if(!empty, " *") ++ if(conflict, " !")' \
              2>/dev/null) || exit 0

            # Flag unpublished work in this stack, excluding empty/immutable changes.
            outgoing=$(jj log --ignore-working-copy --no-graph --color=never --limit 1 \
              -r '::@ ~ immutable() ~ ::remote_bookmarks(remote=origin) ~ empty()' \
              -T '" ↑"' 2>/dev/null)
            printf '%s%s\n' "$state" "$outgoing"
            exit 0
          elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || branch=detached
            while IFS= read -r entry; do
              index=''${entry:0:1}
              worktree=''${entry:1:1}
              case "$index$worktree" in
                DD|AU|UD|UA|DU|AA|UU) conflict='!'; dirty='*' ;;
                '??') dirty='*' ;;
                *)
                  [[ $index != ' ' || $worktree != ' ' ]] && dirty='*'
                  ;;
              esac
            done < <(git status --porcelain=v1 --untracked-files=normal 2>/dev/null)

            # Prefer the upstream, falling back to the same-name origin branch.
            upstream=$(git rev-parse --verify --symbolic-full-name '@{upstream}' 2>/dev/null) || upstream=
            if [[ -z $upstream && $branch != detached ]]; then
              upstream=$(git rev-parse --verify --symbolic-full-name "refs/remotes/origin/$branch" 2>/dev/null) || upstream=
            fi
            if [[ -n $upstream ]]; then
              read -r local_count remote_count < <(git rev-list --left-right --count "HEAD...$upstream" 2>/dev/null)
              [[ ''${local_count:-0} -gt 0 ]] && ahead=1
              [[ ''${remote_count:-0} -gt 0 ]] && behind=1
            fi
          else
            exit 0
          fi

          printf '%s' "$branch"
          [[ -n $dirty ]] && printf ' %s' "$dirty"
          [[ -n $conflict ]] && printf ' %s' "$conflict"
          if [[ -n $ahead && -n $behind ]]; then
            printf ' ↕'
          elif [[ -n $ahead ]]; then
            printf ' ↑'
          elif [[ -n $behind ]]; then
            printf ' ↓'
          fi
          printf '\n'
        '';
      });
      when = "${pkgs.jujutsu}/bin/jj root --ignore-working-copy >/dev/null 2>&1 || ${pkgs.git}/bin/git rev-parse --is-inside-work-tree >/dev/null 2>&1";
      shell = ["${pkgs.bash}/bin/bash" "--noprofile" "--norc"];
      style = "gray";
      format = "[$output]($style) ";
    };

    # Identify the VM even in console shells or sessions without SSH metadata.
    hostname = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      ssh_only = false;
      ssh_symbol = "";
      format = "[\\[$hostname\\]]($style) ";
      style = "bold yellow";
    };

    fill.symbol = " ";

    directory = {
      style = "blue";
      read_only = " 󱌃";
      home_symbol = "~";
      truncation_length = 2;
      truncate_to_repo = false;
      truncation_symbol = ".../";
    };

    character = {
      format = "$symbol ";
      success_symbol = "[❯](purple)";
      error_symbol = "[❯](red)";
    };

    cmd_duration = {
      min_time = 5001;
      format = "[$duration]($style)";
      style = "yellow";
    };
  };
}
