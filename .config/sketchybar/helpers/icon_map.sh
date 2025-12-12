#!/bin/bash

# Icon map function for sketchybar-app-font
# Maps application names to their corresponding icon ligatures

icon_result=""

__icon_map() {
  case "$1" in
  # Browsers
  "Brave Browser" | "Brave")
    icon_result=":brave_browser:"
    ;;
  "Safari" | "Safari Technology Preview")
    icon_result=":safari:"
    ;;
  "Firefox" | "Firefox Developer Edition" | "Firefox Nightly")
    icon_result=":firefox:"
    ;;
  "Google Chrome" | "Chrome")
    icon_result=":google_chrome:"
    ;;
  "Arc")
    icon_result=":arc:"
    ;;
  "Zen Browser")
    icon_result=":firefox:"
    ;;

  # Terminals
  "Ghostty")
    icon_result=":ghostty:"
    ;;
  "Terminal" | "Terminal.app")
    icon_result=":terminal:"
    ;;
  "iTerm" | "iTerm2")
    icon_result=":iterm:"
    ;;
  "Alacritty")
    icon_result=":alacritty:"
    ;;
  "Kitty")
    icon_result=":kitty:"
    ;;
  "WezTerm")
    icon_result=":wezterm:"
    ;;

  # Editors & IDEs
  "Code" | "Visual Studio Code" | "VSCode")
    icon_result=":code:"
    ;;
  "Cursor")
    icon_result=":code:"
    ;;
  "Zed")
    icon_result=":zed:"
    ;;
  "Neovim" | "VimR")
    icon_result=":neovim:"
    ;;

  # Communication
  "Slack")
    icon_result=":slack:"
    ;;
  "Discord" | "Discord PTB" | "Discord Canary")
    icon_result=":discord:"
    ;;
  "Telegram")
    icon_result=":telegram:"
    ;;
  "Signal")
    icon_result=":signal:"
    ;;
  "WhatsApp")
    icon_result=":whats_app:"
    ;;
  "Messages")
    icon_result=":messages:"
    ;;
  "Zoom" | "zoom.us")
    icon_result=":zoom:"
    ;;
  "Microsoft Teams")
    icon_result=":microsoft_teams:"
    ;;

  # Productivity
  "Notion")
    icon_result=":notion:"
    ;;
  "Obsidian")
    icon_result=":obsidian:"
    ;;
  "Notes")
    icon_result=":notes:"
    ;;
  "Reminders")
    icon_result=":reminders:"
    ;;
  "Calendar")
    icon_result=":calendar:"
    ;;
  "Trello")
    icon_result=":trello:"
    ;;

  # Design
  "Figma")
    icon_result=":figma:"
    ;;
  "Sketch")
    icon_result=":sketch:"
    ;;
  "Adobe Photoshop" | "Photoshop")
    icon_result=":photoshop:"
    ;;
  "Adobe Illustrator" | "Illustrator")
    icon_result=":illustrator:"
    ;;

  # Email & Web Apps
  "Mail" | "Mail.app")
    icon_result=":mail:"
    ;;
  "Proton Mail" | "ProtonMail")
    icon_result=":mail:"
    ;;
  "Spark")
    icon_result=":spark:"
    ;;

  # Media
  "Music" | "Music.app")
    icon_result=":music:"
    ;;
  "Spotify")
    icon_result=":spotify:"
    ;;
  "TV" | "Apple TV")
    icon_result=":tv:"
    ;;
  "VLC")
    icon_result=":vlc:"
    ;;
  "IINA")
    icon_result=":iina:"
    ;;

  # Utilities
  "Finder")
    icon_result=":finder:"
    ;;
  "System Settings" | "System Preferences")
    icon_result=":gear:"
    ;;
  "Activity Monitor")
    icon_result=":activity_monitor:"
    ;;
  "Raycast")
    icon_result=":raycast:"
    ;;
  "Alfred")
    icon_result=":alfred:"
    ;;
  "1Password")
    icon_result=":one_password:"
    ;;
  "Proton Pass" | "ProtonPass")
    icon_result=":key:"
    ;;
  "Proton VPN" | "ProtonVPN")
    icon_result=":protonvpn:"
    ;;
  "Proton Drive" | "ProtonDrive")
    icon_result=":proton_drive:"
    ;;

  # Development
  "Docker" | "Docker Desktop")
    icon_result=":docker:"
    ;;
  "Postman")
    icon_result=":postman:"
    ;;
  "Insomnia")
    icon_result=":insomnia:"
    ;;
  "TablePlus")
    icon_result=":table_plus:"
    ;;
  "DBeaver")
    icon_result=":dbeaver:"
    ;;

  # AI Tools
  "Claude" | "Claude for Desktop")
    icon_result=":claude:"
    ;;
  "ChatGPT")
    icon_result=":chat_gpt:"
    ;;

  # Default fallback
  *)
    icon_result=":default:"
    ;;
  esac
}

# Export the function so it can be sourced
export -f __icon_map
