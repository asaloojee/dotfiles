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
          staged=
          conflict=
          ahead=
          behind=
          added=
          removed=

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
                  [[ $index != ' ' ]] && staged='~'
                  [[ $worktree != ' ' ]] && dirty='*'
                  ;;
              esac
            done < <(git status --porcelain=v1 --untracked-files=normal 2>/dev/null)

            # Compare tracked working-copy contents (including staged changes) to HEAD.
            while IFS=$'\t' read -r additions deletions _; do
              [[ $additions =~ ^[0-9]+$ && $additions -gt 0 ]] && added=1
              [[ $deletions =~ ^[0-9]+$ && $deletions -gt 0 ]] && removed=1
            done < <(git diff --numstat HEAD -- 2>/dev/null)

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
          printf '%s' "$dirty$staged$conflict"
          if [[ -n $ahead && -n $behind ]]; then
            printf ' ↕'
          elif [[ -n $ahead ]]; then
            printf ' ↑'
          elif [[ -n $behind ]]; then
            printf ' ↓'
          fi
          if [[ -n $added && -n $removed ]]; then
            printf ' ±'
          elif [[ -n $added ]]; then
            printf ' +'
          elif [[ -n $removed ]]; then
            printf ' −'
          fi
          printf '\n'
        '';
      });
      when = "${pkgs.jujutsu}/bin/jj root --ignore-working-copy >/dev/null 2>&1 || ${pkgs.git}/bin/git rev-parse --is-inside-work-tree >/dev/null 2>&1";
      shell = ["${pkgs.bash}/bin/bash" "--noprofile" "--norc"];
      style = "bright-black";
      format = "[$output]($style) ";
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

    cmd_duration = {
      min_time = 5001;
      format = "[$duration]($style)";
      style = "yellow";
    };
  };
}
