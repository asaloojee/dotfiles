function git --description 'Wrapper for git that enforces running from repository root'
    # Get the repository root
    set repo_root (command git rev-parse --show-toplevel 2>/dev/null)

    # If we're in a git repo, normalize both paths for comparison
    if test -n "$repo_root"
        # Get canonical path of current directory (resolves case on case-insensitive filesystems)
        set current_dir (realpath "$PWD" 2>/dev/null || echo "$PWD")
        set canonical_root (realpath "$repo_root" 2>/dev/null || echo "$repo_root")

        # Block if not at repo root
        if test "$current_dir" != "$canonical_root"
            echo "ERROR: Git commands must be run from repository root!" >&2
            echo "Current: $PWD" >&2
            echo "Root:    $repo_root" >&2
            echo "" >&2
            echo "Run: cd $repo_root" >&2
            return 1
        end
    end

    # Otherwise, run git normally
    command git $argv
end
