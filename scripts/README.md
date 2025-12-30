# Scripts

This directory contains utility scripts that are **version controlled but not symlinked** by Stow.

## Why not symlinked?

These scripts are installed to `~/.local/bin/` which is already in your PATH. We don't want Stow to manage them because:
1. They need to be executable in a specific location (`~/.local/bin`)
2. We want version control without automatic symlinking
3. On a new Mac setup, you manually install them once

## Installation

### On a new Mac:

```bash
cd ~/dotfiles
./scripts/install.sh
```

### To update scripts:

```bash
cd ~/dotfiles
./scripts/install.sh --force
```

## Available Scripts

### tailscale-nuclear-reset.sh

Nuclear option for troubleshooting Tailscale connectivity issues.

**Usage:**
```bash
tailscale-nuclear-reset.sh stop      # Forcefully stop all Tailscale processes
tailscale-nuclear-reset.sh start     # Start Tailscale after nuclear stop
tailscale-nuclear-reset.sh restart   # Full nuclear restart
```

**When to use:**
- Normal `brew services restart tailscale` doesn't work
- Tailscale daemon is stuck or unresponsive
- LaunchAgents/Daemons won't unload properly

**For normal usage, just use:**
```bash
brew services restart tailscale
```

## Adding New Scripts

1. Add your script to this directory: `~/dotfiles/scripts/your-script.sh`
2. Make it executable: `chmod +x ~/dotfiles/scripts/your-script.sh`
3. Run the installer: `./scripts/install.sh --force`
4. Commit to git: `git add scripts/your-script.sh && git commit`

The installer will automatically copy all `.sh` files (except `install.sh`) to `~/.local/bin/`.
