#!/usr/bin/env bash
set -euo pipefail

install_aur() {
    paru -Q "$1" &>/dev/null || paru -S --noconfirm --needed "$1"
}

# Login manager — git version for Wayland stability
# sddm (stable) must be removed first; sddm-git conflicts with it
sudo pacman -Rdd --noconfirm sddm 2>/dev/null || true
install_aur sddm-git

# Cursor
install_aur phinger-cursors

# Desktop widgets
install_aur quickshell

# Bluetooth TUI
install_aur bluetuith

# Screenshot
install_aur grimblast-git

echo "--- Layer 2 verification ---"
paru -Q sddm-git
paru -Q phinger-cursors
echo "--- Layer 2 complete ---"
