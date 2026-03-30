{pkgs, ...}: {
  services.sketchybar = {
    enable = true;
    extraPackages = [pkgs.jq pkgs.sketchybar-app-font];
    config = ''
      # ── Bar appearance ──────────────────────────────────
      sketchybar --bar height=33 \
                      position=top \
                      color=0xff1a1b26 \
                      shadow=off \
                      sticky=on

      # ── Defaults ────────────────────────────────────────
      sketchybar --default icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                           label.font="JetBrainsMono Nerd Font:Bold:14.0" \
                           icon.color=0xffa9b1d6 \
                           label.color=0xffa9b1d6 \
                           padding_left=4 \
                           padding_right=4

      # ── Workspaces ──────────────────────────────────────
      for sid in 1 2 3 4 5; do
        sketchybar --add item space.$sid left \
                   --set space.$sid icon="$sid" \
                                    icon.padding_left=10 \
                                    icon.padding_right=8 \
                                    label.font="sketchybar-app-font:Regular:16.0" \
                                    label.drawing=off \
                                    label.padding_right=8 \
                                    background.color=0xff7aa2f7 \
                                    background.corner_radius=5 \
                                    background.height=24 \
                                    background.drawing=off \
                                    click_script="aerospace workspace $sid"
      done

      # Hidden observer — subscribes to workspace + app events, updates all 5 items
      sketchybar --add item space_observer left \
                 --set space_observer drawing=off \
                                      script='
                                        . icon_map.sh
                                        FOCUSED=$(aerospace list-workspaces --focused)
                                        FRONT_APP=$(osascript -e "tell application \"System Events\" to get name of first application process whose frontmost is true" 2>/dev/null)
                                        FRONT_APP="$(echo "$FRONT_APP" | awk "{print toupper(substr(\$0,1,1)) substr(\$0,2)}")"
                                        __icon_map "$FRONT_APP"
                                        for sid in 1 2 3 4 5; do
                                          if [ "$sid" = "$FOCUSED" ]; then
                                            sketchybar --set space.$sid background.drawing=on \
                                                                        icon.color=0xff1a1b26 \
                                                                        label="$icon_result" \
                                                                        label.drawing=on \
                                                                        label.color=0xff1a1b26
                                          else
                                            sketchybar --set space.$sid background.drawing=off \
                                                                        icon.color=0xffa9b1d6 \
                                                                        label.drawing=off
                                          fi
                                        done
                                      ' \
                 --subscribe space_observer aerospace_workspace_change front_app_switched

      # ── Clock ───────────────────────────────────────────
      sketchybar --add item clock right \
                 --set clock update_freq=30 \
                             icon="󰥔" \
                             icon.padding_right=8 \
                             label.padding_left=0 \
                             script='sketchybar --set $NAME label="$(date "+%a %d %b %H:%M")"'

      # ── Battery ─────────────────────────────────────────
      sketchybar --add item battery right \
                 --set battery update_freq=120 \
                               icon.padding_right=8 \
                               label.padding_left=0 \
                               padding_right=10 \
                               script='
                                 PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | head -1)
                                 CHARGING=$(pmset -g batt | grep -c "AC Power")
                                 if [ "$CHARGING" -gt 0 ]; then
                                   ICON="󰂄"
                                 else
                                   ICON="󰁹"
                                 fi
                                 sketchybar --set $NAME icon="$ICON" label="$PERCENTAGE"
                               '

      # ── Init ────────────────────────────────────────────
      sketchybar --update
    '';
  };
}
