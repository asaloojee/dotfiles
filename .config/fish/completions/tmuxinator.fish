# Fish shell completions for tmuxinator
# Generate project completions dynamically

function __tmuxinator_projects
    tmuxinator completions start 2>/dev/null
end

function __tmuxinator_commands
    echo "commands\ncompletions\nnew\nedit\nopen\nstart\nstop\nlocal\ndebug\ncopy\ndelete\nimplode\nversion\ndoctor\nlist"
end

# Main tmuxinator completions
complete -c tmuxinator -f

# Subcommands
complete -c tmuxinator -n "__fish_use_subcommand" -a "(__tmuxinator_commands)"

# Project-specific completions for relevant subcommands
complete -c tmuxinator -n "__fish_seen_subcommand_from start" -a "(__tmuxinator_projects)"
complete -c tmuxinator -n "__fish_seen_subcommand_from open" -a "(__tmuxinator_projects)"
complete -c tmuxinator -n "__fish_seen_subcommand_from edit" -a "(__tmuxinator_projects)"
complete -c tmuxinator -n "__fish_seen_subcommand_from copy" -a "(__tmuxinator_projects)"
complete -c tmuxinator -n "__fish_seen_subcommand_from delete" -a "(__tmuxinator_projects)"
complete -c tmuxinator -n "__fish_seen_subcommand_from debug" -a "(__tmuxinator_projects)"

# Completions for 'mux' alias
complete -c mux -f
complete -c mux -n "__fish_use_subcommand" -a "(__tmuxinator_commands)"
complete -c mux -n "__fish_seen_subcommand_from start" -a "(__tmuxinator_projects)"
complete -c mux -n "__fish_seen_subcommand_from open" -a "(__tmuxinator_projects)"
complete -c mux -n "__fish_seen_subcommand_from edit" -a "(__tmuxinator_projects)"
complete -c mux -n "__fish_seen_subcommand_from copy" -a "(__tmuxinator_projects)"
complete -c mux -n "__fish_seen_subcommand_from delete" -a "(__tmuxinator_projects)"
complete -c mux -n "__fish_seen_subcommand_from debug" -a "(__tmuxinator_projects)"
