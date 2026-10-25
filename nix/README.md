# macOS workstation and headless development VM

## Hosts and shared modules

- `darwinConfigurations.mac`: the existing ARM64 Mac, still named
  `omnx-mac`. Homebrew, GUI applications, fonts, Aerospace, Ghostty, SketchyBar,
  and macOS settings remain Mac-only.
- `nixosConfigurations.dev`: an ARM64 NixOS VM named `dev`, with user
  `asaloojee`, Fish, Home Manager, Tailscale SSH, and Docker. No desktop environment,
  display server, or GUI applications are enabled. Rex runs on the Mac, not
  inside the VM.
- `modules/shared.nix`: common Nix settings, Rust overlay, package imports,
  and Home Manager integration.
- `modules/packages.nix`: shared CLI/development packages, grouped by purpose.
- `modules/rust.nix`: shared nightly Rust toolchain, Cargo, Clippy, rustfmt,
  rust-src, rust-analyzer, and the `wasm32-unknown-unknown` target.
- `home.nix` and `home/*.nix`: shared terminal configuration, with the desktop
  programs enabled only on Darwin.
- `hosts/dev-vm/default.nix`: VM identity, user, SSH policy, Docker, maintenance,
  and Linux-only packages.
- `hosts/dev-vm/hardware-configuration.nix`: bootstrap disk assumptions;
  **replace with the generated configuration from the actual VM**.

The Mac flake selector remains `#mac`. The Fish `rebuild`
alias selects the correct host on each OS; the root justfile's `rebuild`
recipe remains Mac-specific.

## Package review

All existing shared CLI packages have been retained. Explicit Node.js and
Python runtimes are new shared additions.

| Scope | Tools |
| --- | --- |
| Shared terminal/editor | Neovim, Pi coding agent, btop, fastfetch, fd, ripgrep, jless, jq, just, OpenSSH, Stow, tree, Yazi |
| Shared Home Manager tools | Fish, Git + Git LFS, Jujutsu, bat, eza, fzf, Starship, zoxide, direnv + nix-direnv |
| Shared version control/secrets/containers | GitHub CLI, git-filter-repo, gitleaks, Doppler, GnuPG, YubiKey Manager, lazydocker |
| Shared languages/package managers | Go, Node.js, pnpm, Python 3, uv, PHP Composer, nightly Rust toolchain |
| Shared formatting/linting/parsing | Alejandra, ast-grep, oxfmt, oxlint, Prettier, Ruff, StyLua, tree-sitter |
| Shared specialist CLIs | Shopify CLI, Potrace |
| Shared language servers | Astro, Docker Compose, Dockerfile, Emmet, Lua, Nix (nil), Svelte, Python (ty), TypeScript, Vue, VS Code HTML/CSS/JSON/ESLint, vtsls, YAML |
| VM-only additions | GCC, GNU Make, CMake, pkg-config, Hunk, tmux |
| VM services | Docker Engine (including its CLI), Tailscale + Tailscale SSH, QEMU guest agent |

### Gaps and review decisions

- **Vite Plus (`vp`)**: currently a Homebrew package on the Mac, absent from
  the pinned nixpkgs input. Not installed on the VM yet; decide how to manage
  its Linux distribution before depending on `vp`.
- Hunk stays Homebrew-managed on macOS and is Nix-managed on Linux.
- YubiKey Manager is retained, but physical token access needs UTM USB
  passthrough and potentially additional smart-card configuration.
- Docker group membership is effectively root access. This is intended as a
  personal development VM, not a multi-user server.
- No database servers or additional language runtimes have been added
  automatically.
- Pi credentials, SSH private keys, cloud credentials, and mutable npm-installed
  agent packages are not copied from the Mac. Configure them separately.

## Adopt the flake on an installed VM (user-run steps)

Install NixOS separately on an **ARM64/aarch64 UTM VM using UEFI**. This
flake is for configuring the installed system, not partitioning or installing
it. Keep the UTM console available throughout the first activation: switching
will disable conventional SSH before Tailscale enrollment is complete.

1. Log into the installed VM through its console as `asaloojee`, with a local
   password and sudo access. Clone this repository into `~/dotfiles`, owned by
   that user. If Git is not installed yet, use `nix-shell -p git` to get it.
2. Replace the checked-in hardware placeholder with the configuration generated
   during your NixOS installation:

   ```sh
   cp /etc/nixos/hardware-configuration.nix \
     ~/dotfiles/nix/hosts/dev-vm/hardware-configuration.nix
   ```

   The flake explicitly imports this copy; it does not automatically read
   `/etc/nixos/configuration.nix` or the hardware file there. Do not use the
   placeholder's disk labels as though they described your actual VM. Review
   any other installation-specific settings in `/etc/nixos/configuration.nix`
   and carry over anything required. In particular, match the VM's
   `system.stateVersion` to the installed system's initial value before switching.
3. Review the package selection and host settings. Ensure any new configuration
   files are included in Git before using Git-backed flake commands; Nix ignores
   untracked files. The hardware file above is already tracked, so replacing it
   does not require staging just to evaluate the flake.
4. Apply the flake **from the UTM console**:

   ```sh
   sudo nixos-rebuild switch --flake ~/dotfiles/nix#dev
   ```

5. Enroll the VM in your tailnet. Run this locally in the VM and follow the
   authentication URL:

   ```sh
   sudo tailscale up --ssh --accept-dns=true
   tailscale status
   ```

   The flake also declares SSH and DNS acceptance via `extraSetFlags` for
   subsequent service starts. Authentication state stays on the VM; no auth
   key or other Tailscale credential belongs in this repository.
6. In the Tailscale admin console:
   - Enable **MagicDNS** and ensure your Mac is connected to the same tailnet
     and using its DNS settings.
   - Approve the VM if your tailnet requires device approval.
   - Ensure the VM's MagicDNS name is `dev` (a name collision may add a suffix).
   - Ensure the tailnet policy allows both network access from your Mac to
     the VM on TCP 22 **and** Tailscale SSH access as the local user
     `asaloojee`. These are separate policy requirements; don't add a root
     login rule unless you intend to allow it.
7. Connect from Rex on the Mac:

   ```sh
   ssh asaloojee@dev
   ```

   If short-name resolution is unavailable, use the VM's full MagicDNS name
   from the admin console. No UTM SSH port forwarding or public SSH key in
   `authorized_keys` is needed. Conventional `sshd` is disabled and the NixOS
   firewall does not open LAN TCP 22. Tailscale handles SSH on the tailnet
   address and controls authentication through your tailnet policy. The shared
   OpenSSH package remains available as a client.
8. In the VM, link the Stow-managed editor configuration:

   ```sh
   cd ~/dotfiles
   stow --target "$HOME/.config" .config
   ```

   Home Manager already manages the terminal tools and Pi configuration links;
   its live links expect the checkout at `~/dotfiles`. The Stow directory also
   contains Mac-only configuration files, but no corresponding apps are
   installed or started on Linux. Neovim plugins and mutable agent packages
   still need their normal first-run setup.

Keep your local password for sudo and the UTM console as the recovery path if
Tailscale, DNS, enrollment, or tailnet policy prevents remote access. This
configuration does not manage your tailnet's policy or MagicDNS setting.

References: [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh) and
[MagicDNS](https://tailscale.com/kb/1081/magicdns).

## Subsequent rebuilds (user-run)

```sh
# On the Mac:
sudo -i darwin-rebuild switch --flake ~/dotfiles/nix#mac

# In the VM:
sudo nixos-rebuild switch --flake ~/dotfiles/nix#dev
```

Both hosts also expose the appropriate command via the Fish `rebuild` alias.
The VM uses OSC 52 for Fish's copy-command shortcut; copying to the Mac
clipboard depends on the connecting terminal allowing OSC 52.

Keep `system.stateVersion` at its initial value when updating inputs.
The VM has not been installed or boot-tested by this configuration change.
