#!/usr/bin/env bash
set -euo pipefail

# Bootstrap paru (AUR helper) — must run before any AUR installs.
# Builds from AUR manually via makepkg since no AUR helper exists yet.
if ! command -v paru &>/dev/null; then
    sudo pacman -S --noconfirm --needed git base-devel

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    (cd "$tmpdir/paru" && makepkg -si --noconfirm)
fi

echo "--- Layer 0 verification ---"
paru --version
echo "--- Layer 0 complete ---"
