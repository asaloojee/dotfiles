#!/usr/bin/env bash
# Run inside an ARM64 NixOS UTM guest, never on the host.
set +x
set -euo pipefail

readonly REPOSITORY=https://github.com/asaloojee/dotfiles.git
readonly STATE_VERSION=26.05

usage() {
  printf '%s\n' \
    'Usage: bash bootstrap-dev-vm.sh install /dev/vda' \
    '       bash bootstrap-dev-vm.sh configure' \
    '' \
    'install:   DESTRUCTIVE; run as root in the NixOS minimal live ISO.' \
    'configure: run as your normal user in the installed guest.' \
    'See nix/README.md. Both stages require an interactive console.'
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

confirm() {
  local answer
  printf '%s [y/N] ' "$1" > /dev/tty
  read -r answer < /dev/tty
  [[ "$answer" == y || "$answer" == Y ]] || fail 'Cancelled.'
}

require_commands() {
  local command
  for command in "$@"; do
    command -v "$command" > /dev/null || fail "Required command not found: $command"
  done
}

install_guest() {
  [[ $# == 1 ]] || fail 'install requires exactly one whole-disk device.'
  [[ $EUID == 0 ]] || fail 'Run install as root in the live ISO.'
  require_commands lsblk readlink parted udevadm cryptsetup mkfs.fat \
    mkfs.ext4 mount mountpoint nixos-version nixos-generate-config nixos-install \
    nixos-enter swapon grep tr cp mkdir
  mountpoint -q /iso || fail 'Expected the NixOS live ISO mounted at /iso.'
  [[ -d /sys/firmware/efi ]] || fail 'Boot the installer in UEFI mode.'
  [[ "$(nixos-version)" == "$STATE_VERSION".* ]] || \
    fail "Use the NixOS $STATE_VERSION minimal ISO for this bootstrap."

  local disk partition_prefix answer mounts devices swap_devices device types type
  disk=$(readlink -f -- "$1")
  [[ -b "$disk" && "$(lsblk -dnro TYPE "$disk")" == disk ]] || \
    fail 'Target must be a whole block disk, not a partition.'
  # Capture probes separately so a failed probe cannot look like an unused disk.
  mounts=$(lsblk -nr -o MOUNTPOINTS "$disk" | tr -d '[:space:]')
  [[ -z "$mounts" ]] || fail 'The target disk or one of its descendants is mounted.'
  types=$(lsblk -nr -o TYPE "$disk")
  while IFS= read -r type; do
    [[ "$type" == disk || "$type" == part ]] || \
      fail "Target has an active block-device mapping: $type"
  done <<< "$types"
  devices=$(lsblk -nrpo NAME "$disk")
  swap_devices=$(swapon --noheadings --raw --show=NAME)
  while IFS= read -r device; do
    if grep -Fxq -- "$device" <<< "$swap_devices"; then
      fail "Target has active swap: $device"
    fi
  done <<< "$devices"
  ! mountpoint -q /mnt || fail '/mnt is already mounted.'
  [[ ! -e /dev/mapper/cryptroot ]] || fail 'cryptroot is already open.'

  lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS "$disk"
  printf '\nALL DATA ON %s WILL BE ERASED. Type ERASE %s to continue: ' \
    "$disk" "$disk" > /dev/tty
  read -r answer < /dev/tty
  [[ "$answer" == "ERASE $disk" ]] || fail 'Cancelled without erasing.'

  partition_prefix=$disk
  [[ "$disk" != *[0-9] ]] || partition_prefix=${disk}p
  parted --script "$disk" -- \
    mklabel gpt \
    mkpart ESP fat32 1MiB 1025MiB \
    set 1 esp on \
    mkpart cryptroot 1025MiB 100%
  udevadm settle

  # cryptsetup and passwd read secrets interactively; never store them here.
  cryptsetup luksFormat --type luks2 "${partition_prefix}2"
  cryptsetup open "${partition_prefix}2" cryptroot
  mkfs.fat -F 32 -n EFI "${partition_prefix}1"
  mkfs.ext4 -L nixos /dev/mapper/cryptroot
  mount /dev/mapper/cryptroot /mnt
  mkdir -p /mnt/boot
  mount "${partition_prefix}1" /mnt/boot
  nixos-generate-config --root /mnt
  cp /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix.original

  cat > /mnt/etc/nixos/configuration.nix <<'NIX'
{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "dev";
  networking.useDHCP = true;
  networking.firewall.enable = true;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_CA.UTF-8";
  users.users.asaloojee = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  security.sudo.wheelNeedsPassword = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [ git ];
  services.qemuGuest.enable = true;
  services.openssh.enable = false;
  system.stateVersion = "26.05";
}
NIX

  nixos-install --no-root-passwd
  printf '\nSet the local login/sudo password for asaloojee (not the LUKS passphrase).\n'
  nixos-enter --root /mnt -c 'passwd asaloojee'
  printf '\nInstallation complete. Inspect the result, then run poweroff.\n'
  printf 'Eject only the ISO in UTM, boot, unlock via serial console, and log in as asaloojee.\n'
  printf 'Do not rerun install to resume a partial installation; see the README.\n'
}

configure_guest() {
  [[ $# == 0 ]] || fail 'configure takes no arguments.'
  [[ $EUID != 0 ]] || fail 'Run configure as asaloojee, not through sudo.'
  [[ "$(id -un)" == asaloojee && "$HOME" == /home/asaloojee ]] || \
    fail 'This personal flake expects user asaloojee with home /home/asaloojee.'
  require_commands git nix sudo cmp grep
  [[ -f /etc/nixos/hardware-configuration.nix ]] || fail 'Installed hardware file is missing.'
  grep -Eq '^[[:space:]]*system\.stateVersion[[:space:]]*=[[:space:]]*"26\.05";' \
    /etc/nixos/configuration.nix || \
    fail "Review the initial system.stateVersion; this bootstrap expects $STATE_VERSION."

  local checkout="$HOME/dotfiles" hardware flake
  if [[ ! -e "$checkout" ]]; then
    git clone "$REPOSITORY" "$checkout"
  else
    [[ "$(git -C "$checkout" rev-parse --show-toplevel)" == "$checkout" ]] || \
      fail '~/dotfiles must be the root of a Git checkout.'
    printf 'Reusing the existing checkout without pulling, resetting, or changing remotes.\n'
    git -C "$checkout" status --short
  fi
  [[ -f "$checkout/nix/flake.nix" && -f "$checkout/nix/hosts/dev-vm/default.nix" ]] || \
    fail 'Expected the dev VM flake in ~/dotfiles/nix.'
  hardware="$checkout/nix/hosts/dev-vm/hardware-configuration.nix"
  [[ ! -L "$hardware" ]] || fail 'Refusing to replace a symlinked hardware file.'
  if [[ -e "$hardware" ]] && ! cmp -s /etc/nixos/hardware-configuration.nix "$hardware"; then
    confirm 'Replace the different hardware configuration in the checkout?'
  fi
  # Refuse accidental publication of this machine-local file in older checkouts.
  git -C "$checkout" check-ignore -q -- nix/hosts/dev-vm/hardware-configuration.nix || \
    fail 'Hardware file must be Git-ignored. Update the checkout or its local exclude rules first.'
  cp /etc/nixos/hardware-configuration.nix "$hardware"

  flake="path:$checkout?dir=nix#dev"
  [[ "$(nix eval --raw --no-write-lock-file \
    "path:$checkout?dir=nix#nixosConfigurations.dev.config.system.stateVersion")" == "$STATE_VERSION" ]] || \
    fail 'The flake stateVersion differs from the initial installation; review before switching.'
  nix eval --raw --no-write-lock-file \
    "path:$checkout?dir=nix#nixosConfigurations.dev.config.system.build.toplevel.drvPath"
  printf '\n'
  confirm 'Build and activate #dev now? Keep the UTM serial console open.'
  sudo nixos-rebuild switch --no-write-lock-file --flake "$flake"
  printf '\nAuthenticate using the URL below in your Mac browser if prompted.\n'
  sudo tailscale up --ssh --accept-dns=true
  tailscale status
  printf '\nFrom Rex on your Mac: ssh asaloojee@dev\n'
  printf 'Verify sudo and Docker, then reboot, unlock via serial console, and reconnect.\n'
  printf 'Tailnet policy must allow both TCP 22 network access and Tailscale SSH.\n'
}

main() {
  case "${1:-}" in
    -h|--help|help) usage; return ;;
    install|configure) ;;
    *) usage >&2; exit 1 ;;
  esac
  [[ "$(uname -s)" == Linux && "$(uname -m)" == aarch64 && -e /etc/NIXOS ]] || \
    fail 'Run only inside an ARM64 NixOS guest.'
  [[ -r /dev/tty && -w /dev/tty ]] || fail 'An interactive console is required.'
  local stage=$1
  shift
  case "$stage" in
    install) install_guest "$@" ;;
    configure) configure_guest "$@" ;;
  esac
}

main "$@"
