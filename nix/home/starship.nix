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
      description = "Branch or jj bookmark with shared status markers";
      command = lib.getExe (pkgs.writeShellApplication {
        name = "starship-vcs";
        runtimeInputs = [pkgs.git pkgs.jujutsu];
        # Status probes legitimately return nonzero for absent refs/markers.
        bashOptions = [];
        text = ''
          export LC_ALL=C
          export GIT_OPTIONAL_LOCKS=0

          names=()
          dirty=
          staged=
          conflict=
          divergent=
          ahead=
          behind=

          if jj root --ignore-working-copy >/dev/null 2>&1; then
            # Snapshot once for up-to-date working-copy markers.
            markers=$(jj log --no-graph --color=never -r @ -T \
              'if(!empty, "*") ++ if(conflict, "!")' 2>/dev/null) || exit 0
            [[ $markers == *'*'* ]] && dirty='*'
            [[ $markers == *'!'* ]] && conflict='!'

            # Use the current bookmark or the closest bookmarked ancestors.
            context='heads(::@ & bookmarks())'
            while IFS=$'\t' read -r name bookmark_conflict; do
              [[ -n $name ]] || continue
              names+=("$name")
              [[ $bookmark_conflict == true ]] && divergent='?'
            done < <(jj bookmark list --ignore-working-copy --color=never -r "$context" \
              -T 'name ++ "\t" ++ conflict ++ "\n"' 2>/dev/null)

            # jj reports tracking counts from the remote's perspective.
            while IFS=$'\t' read -r remote_ahead remote_behind; do
              [[ $remote_ahead == true ]] && behind=1
              [[ $remote_behind == true ]] && ahead=1
            done < <(jj bookmark list --ignore-working-copy --color=never --tracked \
              -r "$context" -T \
              'if(remote, !tracking_ahead_count.zero() ++ "\t" ++ !tracking_behind_count.zero() ++ "\n")' \
              2>/dev/null)

            ((''${#names[@]})) || names=(unbookmarked)
          elif git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) || branch=detached
            names=("$branch")
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

          separator=
          for name in "''${names[@]}"; do
            printf '%s%s' "$separator" "$name"
            separator=,
          done
          printf '%s' "$dirty$staged$conflict$divergent"
          if [[ -n $ahead && -n $behind ]]; then
            printf ' ±'
          elif [[ -n $ahead ]]; then
            printf ' +'
          elif [[ -n $behind ]]; then
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
