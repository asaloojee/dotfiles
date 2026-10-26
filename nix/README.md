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
- `bootstrap-dev-vm.sh`: interactive, two-stage installer for an encrypted UTM guest.
- `hosts/dev-vm/hardware-configuration.nix`: generated inside each guest and
  Git-ignored; absent from this public repository.

The Mac flake selector remains `#mac`; the root justfile's `rebuild` recipe
remains Mac-specific. For VM rebuilds, use the explicit `path:` command below:
the current Fish `rebuild` alias uses a Git-backed reference that excludes the
ignored hardware file.

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

## Recreate the encrypted UTM VM

The two-stage bootstrap follows the manually verified installation: first a small
bootable NixOS base, then the personal flake. It is intentionally specific to
ARM64 NixOS, user `asaloojee`, checkout `~/dotfiles`, and initial
`system.stateVersion = "26.05"`. It is not an unattended or general-purpose installer.

### 1. Create the VM (on the Mac)

In UTM, choose **Virtualize → Linux**, using the QEMU backend (leave **Use Apple
Virtualization** off). Select a NixOS **26.05 minimal aarch64** ISO.

- 4 CPU cores, 8192 MiB RAM, 128 GiB VirtIO disk.
- UEFI boot; boot from ISO, not a direct kernel image.
- Shared Network; no bridged adapter or SSH port forwarding required.
- Add a **serial console** and keep it attached for boot and disk unlocking.
  The graphical display may say “Display output is not active”; use serial.
- No shared directories, desktop, camera, sound, or USB passthrough required.

The tested manual installation used UTM 5.0.8 on Apple Silicon. The guest disk
contains an unencrypted 1 GiB EFI partition and a LUKS2-encrypted ext4 root.
There is no disk swap. **Every cold boot/reboot requires entering the LUKS
passphrase in UTM before Tailscale becomes available.** Loss of the passphrase
means loss of access to the encrypted data; keep it in a password manager.
Guest encryption does not protect a running/unlocked VM or its saved memory.

### 2. Bootstrap the disk (inside the live ISO)

Use the UTM console. Inspect architecture, connectivity, and the actual disk:

```sh
uname -m
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
curl -I https://github.com
```

Fetch the script to a file and inspect it; **do not pipe a download into a root
shell**. Once these changes are published, the following works in the live ISO:

```sh
curl --fail --show-error --location \
  https://raw.githubusercontent.com/asaloojee/dotfiles/main/nix/bootstrap-dev-vm.sh \
  --output /tmp/bootstrap-dev-vm.sh
less /tmp/bootstrap-dev-vm.sh
```

For repeatable use, replace `main` with a reviewed commit SHA. The script URL
must reference a revision containing the script. Git availability is not required
in the live ISO; it is included in the installed base.

**Destructive command — only inside the guest, after verifying the disk:**

```sh
sudo bash /tmp/bootstrap-dev-vm.sh install /dev/vda
```

The script refuses mounted disks/active swap, requires typing the exact erase
confirmation, then partitions and formats the selected disk. It prompts for the
LUKS passphrase, installs the base, and prompts for the local login/sudo password.
These are separate credentials. No secrets are stored in the script or repository.

When it finishes, inspect the result, run `sudo poweroff`, eject **only the ISO**
in UTM, and boot again. Unlock via serial console and log in as `asaloojee`.

If a step fails, stop and inspect it. The install stage is **not resumable by
rerunning it**: it deliberately refuses mounted disks. Do not reformat to fix an
installation error. If filesystems remain mounted, correct the issue and rerun
`sudo nixos-install --no-root-passwd`, then set the account password with:

```sh
sudo nixos-enter --root /mnt -c 'passwd asaloojee'
```

Do not shut down before setting that password. For recovery after a reboot, boot
the ISO and unlock/mount the existing filesystems without formatting:

```sh
sudo cryptsetup open /dev/vda2 cryptroot
sudo mount /dev/mapper/cryptroot /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/vda1 /mnt/boot
```

Recheck device names first. If `cryptroot` is already open or filesystems are
already mounted, don't repeat those operations. Never repeat `luksFormat` or
`mkfs` as a recovery step.

### 3. Apply the personal flake (inside the installed VM)

First verify `findmnt /`, `findmnt /boot`, `sudo cryptsetup status cryptroot`,
and HTTPS connectivity. Then, as the normal user:

```sh
git clone https://github.com/asaloojee/dotfiles.git ~/dotfiles
bash ~/dotfiles/nix/bootstrap-dev-vm.sh configure
```

Use a reviewed revision containing the bootstrap changes. If `~/dotfiles`
already exists, skip cloning and review/update it yourself: the script never
pulls, resets, or changes remotes. It can also clone when run from a separately
downloaded script and no checkout exists.

The configure stage:

1. Checks the initial installed `system.stateVersion` is `26.05`.
2. Copies `/etc/nixos/hardware-configuration.nix` into the flake, asking before
   replacing a different copy. The file is Git-ignored and stays on the guest.
3. Evaluates the complete configuration, then asks before building/activating it.
4. Starts interactive Tailscale enrollment. Open its URL in your Mac browser.

It does not update `flake.lock`, stage files, transfer private keys, or change
Tailscale policy. Review the package list before approving activation; Docker
group membership grants effectively root-level access.

The whole-repository `path:` reference is important: it includes the ignored
hardware file **and** the shared Neovim palette outside `nix/`. Do not use
`path:~/dotfiles/nix` or work around missing source files with `--impure`.

**Public-repository hygiene:** never commit passwords, private keys, Tailscale
auth keys/state, or cloud/agent credentials. Disk UUIDs aren't passwords, but
hardware files are machine-local and deliberately excluded. Ignored files are
not a security boundary: the `path:` source can include them in the Nix store,
which is locally readable. Keep secrets outside the checkout and Nix expressions.

### 4. Connect from Rex and verify persistence

In your personal tailnet's admin console:

- Enable MagicDNS and ensure the Mac uses Tailscale DNS.
- Approve the guest if required; check whether its assigned name is `dev` or
  has a collision suffix.
- Allow both network access on TCP 22 **and** Tailscale SSH as `asaloojee`.
  These are separate policy rules; root SSH access is not required.

From a local Rex pane on the Mac:

```sh
ssh asaloojee@dev
```

Use the full MagicDNS name or `tailscale ip -4` address if short-name resolution
fails. No conventional sshd, authorized key, or UTM port forwarding is required.
Tailscale handles authentication; the local password remains necessary for sudo.

In the remote session:

```sh
whoami
hostname
echo "$SHELL"
sudo -v
systemctl --failed
systemctl is-active tailscaled docker
docker run --rm hello-world
```

Then run `sudo reboot`, unlock the disk in UTM's serial console, reconnect from
Rex, and repeat the service checks and `findmnt /`. This encrypted boot → flake
activation → Tailscale SSH → Docker → reboot/reconnect path was manually verified.
The script automates those steps but still needs a separate clean-VM test.

### 5. Optional editor setup

Preview the Stow-managed editor links before applying them:

```sh
cd ~/dotfiles
stow --simulate --verbose --target "$HOME/.config" .config
stow --target "$HOME/.config" .config
```

Home Manager already manages terminal tools and Pi configuration links; its live
links expect `~/dotfiles`. The Stow directory also includes Mac-only configuration,
but corresponding applications are not installed or started on Linux. Neovim
plugins, mutable agent packages, and credentials need their own first-run setup.
The bootstrap deliberately does not adopt or overwrite existing editor files.

## Subsequent rebuilds (user-run)

```sh
# On the Mac (unchanged):
sudo -i darwin-rebuild switch --flake ~/dotfiles/nix#mac

# In the VM (includes the ignored hardware file and shared palette):
sudo nixos-rebuild switch --no-write-lock-file \
  --flake "path:$HOME/dotfiles?dir=nix#dev"
```

Use the explicit VM command rather than the current Fish `rebuild` alias.
Keep `system.stateVersion` at its initial value when updating inputs. A newer
NixOS package version does not require changing this compatibility baseline.

Keep the local password and UTM serial console as recovery paths if Tailscale,
DNS, enrollment, or policy prevents SSH. The VM uses OSC 52 for Fish's copy-command
shortcut; the connecting terminal must permit OSC 52 to reach the Mac clipboard.

References: [UTM](https://docs.getutm.app/),
[Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh), and
[MagicDNS](https://tailscale.com/kb/1081/magicdns).
