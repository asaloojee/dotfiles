# Fish greeting
set fish_greeting ""

# Locale settings
set -gx LC_ALL en_CA.UTF-8
set -gx LANG en_CA.UTF-8

# Editor
set -gx EDITOR nvim

# Starship configuration
set -gx STARSHIP_CONFIG ~/.config/starship/starship.toml

# PATH management - fish_add_path handles duplicates automatically
fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path $HOME/google-cloud-sdk/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /nix/var/nix/profiles/default/bin
fish_add_path /run/current-system/sw/bin

# Aliases
alias ls="eza --icons=always"
alias g="gitui"
alias mux="tmuxinator"
# Fully shutdown tailscale (useful for manual troubleshooting)
function tailscale-stop
    echo "🛑 Shutting down tailscale completely..."
    tailscale down 2>/dev/null || true
    brew services stop tailscale 2>/dev/null || true
    sudo brew services stop tailscale 2>/dev/null || true
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.tailscale.plist 2>/dev/null || true
    sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.tailscale.plist 2>/dev/null || true
    pkill -9 tailscaled 2>/dev/null || true
    sudo pkill -9 tailscaled 2>/dev/null || true
    echo "✅ Tailscale fully stopped"
end

# Fully start tailscale
function tailscale-start
    echo "🚀 Starting tailscale..."
    sudo brew services start tailscale
    sleep 2
    tailscale up 2>/dev/null || echo "⚠️  Run 'tailscale up' manually if needed"
    echo "✅ Tailscale started"
end

# Rebuild system with automatic service management
function rebuild
    # Fully shutdown tailscale before rebuild
    echo "🛑 Shutting down tailscale completely..."

    # 1. Disconnect from tailscale network
    tailscale down 2>/dev/null || true

    # 2. Stop brew service (tries both user and system level)
    brew services stop tailscale 2>/dev/null || true
    sudo brew services stop tailscale 2>/dev/null || true

    # 3. Unload launchd agents/daemons
    launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.tailscale.plist 2>/dev/null || true
    sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.tailscale.plist 2>/dev/null || true

    # 4. Kill any remaining tailscaled processes
    pkill -9 tailscaled 2>/dev/null || true
    sudo pkill -9 tailscaled 2>/dev/null || true

    echo "✅ Tailscale fully stopped"
    sleep 1

    # Run darwin-rebuild
    echo "🔄 Running darwin-rebuild..."
    sudo darwin-rebuild switch --flake ~/dotfiles/nix#mac

    # Restart tailscale after successful rebuild
    if test $status -eq 0
        echo "✅ Rebuild successful, restarting tailscale..."
        sudo brew services start tailscale
        sleep 2
        tailscale up 2>/dev/null || echo "⚠️  Run 'tailscale up' manually if needed"
    else
        echo "❌ Rebuild failed, tailscale not restarted"
        return 1
    end
end
alias n="nvim"
alias cc="claude"

# Yazi file manager with directory changing
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# Interactive directory navigation with lstr
function lcd
    set -l selected_dir (lstr interactive -g --icons)
    if test -n "$selected_dir" -a -d "$selected_dir"
        cd "$selected_dir"
    end
end

# Git commit helper
function gc
    $HOME/.local/bin/git-commit.fish $argv
end

# Jump to git repository root
function gr
    set -l root (command git rev-parse --show-toplevel 2>/dev/null)
    if test -n "$root"
        builtin cd "$root"
    else
        echo "Not in a git repository"
        return 1
    end
end

# Zoxide (smarter cd)
zoxide init fish | source
alias cd="z"

# Set NODE_ENV to development for local development
set -gx NODE_ENV development

# ========================================
# JavaScript/TypeScript Development Setup
# ========================================

# Bun environment variables
set -gx BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin

# Use Bun as the default Node.js runtime
# Bun is highly compatible with Node.js and much faster
alias node="bun"
alias node-real="command node" # Access real Node.js if needed

# Bun shell completions (enable tab completion)
if test -f "$BUN_INSTALL/_bun"
    source "$BUN_INSTALL/_bun"
end

# Smart package manager detector
# Detects which package manager to use based on lockfiles in current directory
function pm
    if test -f bun.lockb
        echo "📦 Using Bun"
        bun $argv
    else if test -f package-lock.json
        echo "📦 Using npm"
        npm $argv
    else if test -f yarn.lock
        echo "📦 Using Yarn"
        yarn $argv
    else if test -f pnpm-lock.yaml
        echo "📦 Using pnpm"
        pnpm $argv
    else
        # Default to Bun if no lockfile found
        echo "📦 Using Bun (default)"
        bun $argv
    end
end

# Common development task aliases (uses smart pm detection)
alias dev="pm run dev"
alias build="pm run build"
alias start="pm run start"
alias lint="pm run lint"
alias format="pm run format"
alias typecheck="pm run typecheck"

# Initialize Starship prompt
starship init fish | source
