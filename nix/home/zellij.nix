{pkgs, ...}: {
  enable = true;

  # Keep startup explicit while testing. If this feels good, we can later enable
  # Zellij's zsh auto-start/auto-attach integration.
  enableZshIntegration = false;

  layouts = {
    tmux = ''
      layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
          }
          pane
      }
    '';

    omniwerx-io = ''
      layout {
          cwd "/Users/asaloojee/dev/omniwerx-io"
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="compact-bar"
              }
          }
          tab name="terminal" focus=true {
              pane
          }
          tab name="editor" {
              pane command="nvim"
          }
          tab name="agent" {
              pane command="pi"
          }
      }
    '';
  };

  extraConfig = ''
    // Tmux-ish defaults: one bottom bar, vi-flavoured navigation, mouse on,
    // session serialization on, and Ctrl-Space as the main prefix.
    default_shell "${pkgs.zsh}/bin/zsh"
    default_layout "tmux"
    default_mode "normal"
    pane_frames true
    auto_layout true
    mouse_mode true
    copy_command "pbcopy"
    copy_clipboard "system"
    copy_on_select true
    scroll_buffer_size 10000
    scrollback_editor "nvim"
    session_serialization true
    serialize_pane_viewport false
    support_kitty_keyboard_protocol true
    show_release_notes false

    themes {
        tokyo-night {
            fg 192 202 245
            bg 26 27 38
            black 21 22 30
            red 247 118 142
            green 158 206 106
            yellow 224 175 104
            blue 122 162 247
            magenta 187 154 247
            cyan 125 207 255
            white 169 177 214
            orange 255 158 100
        }
    }
    theme "tokyo-night"

    plugins {
        tab-bar location="zellij:tab-bar"
        status-bar location="zellij:status-bar"
        strider location="zellij:strider"
        compact-bar location="zellij:compact-bar"
        session-manager location="zellij:session-manager"
        welcome-screen location="zellij:session-manager" {
            welcome_screen true
        }
        filepicker location="zellij:strider" {
            cwd "/"
        }
        configuration location="zellij:configuration"
        plugin-manager location="zellij:plugin-manager"
        about location="zellij:about"
    }

    load_plugins {
        "zellij:link"
    }

    keybinds clear-defaults=true {
        normal {
            // Keep Normal quiet; tmux-style interactions mostly live behind Ctrl-Space.
        }

        locked {
            bind "Ctrl Space" { SwitchToMode "Normal"; }
            bind "Ctrl g" { SwitchToMode "Normal"; }
        }

        resize {
            bind "Ctrl n" { SwitchToMode "Normal"; }
            bind "h" "Left" { Resize "Increase Left"; }
            bind "j" "Down" { Resize "Increase Down"; }
            bind "k" "Up" { Resize "Increase Up"; }
            bind "l" "Right" { Resize "Increase Right"; }
            bind "H" { Resize "Decrease Left"; }
            bind "J" { Resize "Decrease Down"; }
            bind "K" { Resize "Decrease Up"; }
            bind "L" { Resize "Decrease Right"; }
            bind "=" "+" { Resize "Increase"; }
            bind "-" { Resize "Decrease"; }
        }

        pane {
            bind "Ctrl p" { SwitchToMode "Normal"; }
            bind "h" "Left" { MoveFocus "Left"; }
            bind "l" "Right" { MoveFocus "Right"; }
            bind "j" "Down" { MoveFocus "Down"; }
            bind "k" "Up" { MoveFocus "Up"; }
            bind "p" { SwitchFocus; }
            bind "n" { NewPane; SwitchToMode "Normal"; }
            bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
            bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
            bind "s" { NewPane "stacked"; SwitchToMode "Normal"; }
            bind "x" { CloseFocus; SwitchToMode "Normal"; }
            bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
            bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
            bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
            bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
            bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
            bind "i" { TogglePanePinned; SwitchToMode "Normal"; }
        }

        move {
            bind "Ctrl h" { SwitchToMode "Normal"; }
            bind "n" "Tab" { MovePane; }
            bind "p" { MovePaneBackwards; }
            bind "h" "Left" { MovePane "Left"; }
            bind "j" "Down" { MovePane "Down"; }
            bind "k" "Up" { MovePane "Up"; }
            bind "l" "Right" { MovePane "Right"; }
        }

        tab {
            bind "Ctrl t" { SwitchToMode "Normal"; }
            bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
            bind "h" "Left" "Up" "k" { GoToPreviousTab; }
            bind "l" "Right" "Down" "j" { GoToNextTab; }
            bind "n" { NewTab; SwitchToMode "Normal"; }
            bind "x" { CloseTab; SwitchToMode "Normal"; }
            bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
            bind "b" { BreakPane; SwitchToMode "Normal"; }
            bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
            bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
            bind "1" { GoToTab 1; SwitchToMode "Normal"; }
            bind "2" { GoToTab 2; SwitchToMode "Normal"; }
            bind "3" { GoToTab 3; SwitchToMode "Normal"; }
            bind "4" { GoToTab 4; SwitchToMode "Normal"; }
            bind "5" { GoToTab 5; SwitchToMode "Normal"; }
            bind "6" { GoToTab 6; SwitchToMode "Normal"; }
            bind "7" { GoToTab 7; SwitchToMode "Normal"; }
            bind "8" { GoToTab 8; SwitchToMode "Normal"; }
            bind "9" { GoToTab 9; SwitchToMode "Normal"; }
            bind "Tab" { ToggleTab; }
        }

        scroll {
            bind "Ctrl s" { SwitchToMode "Normal"; }
            bind "e" { EditScrollback; SwitchToMode "Normal"; }
            bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
            bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
        }

        search {
            bind "Ctrl s" { SwitchToMode "Normal"; }
            bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "Ctrl f" "PageDown" "Right" "l" { PageScrollDown; }
            bind "Ctrl b" "PageUp" "Left" "h" { PageScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
            bind "n" { Search "down"; }
            bind "p" { Search "up"; }
            bind "c" { SearchToggleOption "CaseSensitivity"; }
            bind "w" { SearchToggleOption "Wrap"; }
            bind "o" { SearchToggleOption "WholeWord"; }
        }

        entersearch {
            bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
            bind "Enter" { SwitchToMode "Search"; }
        }

        renametab {
            bind "Ctrl c" { SwitchToMode "Normal"; }
            bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
        }

        renamepane {
            bind "Ctrl c" { SwitchToMode "Normal"; }
            bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
        }

        session {
            bind "Ctrl o" { SwitchToMode "Normal"; }
            bind "Ctrl s" { SwitchToMode "Scroll"; }
            bind "d" { Detach; }
            bind "w" {
                LaunchOrFocusPlugin "session-manager" {
                    floating true
                    move_to_focused_tab true
                }
                SwitchToMode "Normal"
            }
            bind "c" {
                LaunchOrFocusPlugin "configuration" {
                    floating true
                    move_to_focused_tab true
                }
                SwitchToMode "Normal"
            }
            bind "p" {
                LaunchOrFocusPlugin "plugin-manager" {
                    floating true
                    move_to_focused_tab true
                }
                SwitchToMode "Normal"
            }
            bind "a" {
                LaunchOrFocusPlugin "zellij:about" {
                    floating true
                    move_to_focused_tab true
                }
                SwitchToMode "Normal"
            }
            bind "s" {
                LaunchOrFocusPlugin "zellij:share" {
                    floating true
                    move_to_focused_tab true
                }
                SwitchToMode "Normal"
            }
            bind "l" {
                LaunchOrFocusPlugin "zellij:layout-manager" {
                    floating true
                    move_to_focused_tab true
                }
                SwitchToMode "Normal"
            }
        }

        tmux {
            bind "[" { SwitchToMode "Scroll"; }
            bind "Ctrl Space" { Write 0; SwitchToMode "Normal"; }
            bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
            bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
            bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
            bind "c" { NewTab; SwitchToMode "Normal"; }
            bind "," { SwitchToMode "RenameTab"; }
            bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
            bind "n" { GoToNextTab; SwitchToMode "Normal"; }
            bind "1" { GoToTab 1; SwitchToMode "Normal"; }
            bind "2" { GoToTab 2; SwitchToMode "Normal"; }
            bind "3" { GoToTab 3; SwitchToMode "Normal"; }
            bind "4" { GoToTab 4; SwitchToMode "Normal"; }
            bind "5" { GoToTab 5; SwitchToMode "Normal"; }
            bind "6" { GoToTab 6; SwitchToMode "Normal"; }
            bind "7" { GoToTab 7; SwitchToMode "Normal"; }
            bind "8" { GoToTab 8; SwitchToMode "Normal"; }
            bind "9" { GoToTab 9; SwitchToMode "Normal"; }
            bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
            bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
            bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
            bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
            bind "L" { Clear; SwitchToMode "Normal"; }
            bind "o" { FocusNextPane; SwitchToMode "Normal"; }
            bind "d" { Detach; }
            bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
            bind "Space" { NextSwapLayout; SwitchToMode "Normal"; }
            bind "x" { CloseFocus; SwitchToMode "Normal"; }
            bind "Up" { Resize "Increase Up"; SwitchToMode "Normal"; }
            bind "Down" { Resize "Increase Down"; SwitchToMode "Normal"; }
            bind "Left" { Resize "Increase Left"; SwitchToMode "Normal"; }
            bind "Right" { Resize "Increase Right"; SwitchToMode "Normal"; }
            bind "Shift Up" { Resize "Increase Up"; Resize "Increase Up"; Resize "Increase Up"; Resize "Increase Up"; Resize "Increase Up"; SwitchToMode "Normal"; }
            bind "Shift Down" { Resize "Increase Down"; Resize "Increase Down"; Resize "Increase Down"; Resize "Increase Down"; Resize "Increase Down"; SwitchToMode "Normal"; }
            bind "Shift Left" { Resize "Increase Left"; Resize "Increase Left"; Resize "Increase Left"; Resize "Increase Left"; Resize "Increase Left"; SwitchToMode "Normal"; }
            bind "Shift Right" { Resize "Increase Right"; Resize "Increase Right"; Resize "Increase Right"; Resize "Increase Right"; Resize "Increase Right"; SwitchToMode "Normal"; }
        }

        shared_except "locked" {
            bind "Ctrl q" { Quit; }
            bind "Alt Left" { MoveFocus "Left"; }
            bind "Alt Right" { MoveFocus "Right"; }
            bind "Alt Up" { MoveFocus "Up"; }
            bind "Alt Down" { MoveFocus "Down"; }
            bind "Shift Left" { GoToPreviousTab; }
            bind "Shift Right" { GoToNextTab; }
            bind "Alt H" "Alt Shift h" { GoToPreviousTab; }
            bind "Alt L" "Alt Shift l" { GoToNextTab; }
            bind "Alt f" { ToggleFloatingPanes; }
            bind "Alt n" { NewPane; }
            bind "Alt =" "Alt +" { Resize "Increase"; }
            bind "Alt -" { Resize "Decrease"; }
            bind "Alt [" { PreviousSwapLayout; }
            bind "Alt ]" { NextSwapLayout; }
            bind "Alt p" { TogglePaneInGroup; }
            bind "Alt Shift p" { ToggleGroupMarking; }
        }

        shared_except "normal" "locked" {
            bind "Enter" "Esc" { SwitchToMode "Normal"; }
        }

        shared_except "pane" "locked" {
            bind "Ctrl p" { SwitchToMode "Pane"; }
        }

        shared_except "resize" "locked" {
            bind "Ctrl n" { SwitchToMode "Resize"; }
        }

        shared_except "scroll" "locked" {
            bind "Ctrl s" { SwitchToMode "Scroll"; }
        }

        shared_except "session" "locked" {
            bind "Ctrl o" { SwitchToMode "Session"; }
        }

        shared_except "tab" "locked" {
            bind "Ctrl t" { SwitchToMode "Tab"; }
        }

        shared_except "move" "locked" {
            bind "Ctrl h" { SwitchToMode "Move"; }
        }

        shared_except "tmux" "locked" {
            bind "Ctrl Space" { SwitchToMode "Tmux"; }
            bind "Ctrl b" { SwitchToMode "Tmux"; }
        }
    }
  '';
}
