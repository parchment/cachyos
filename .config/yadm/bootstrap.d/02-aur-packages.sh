#!/usr/bin/env bash
set -euo pipefail

install_aur() {
    paru -Q "$1" &>/dev/null || paru -S --noconfirm --needed "$1"
}

# GTK dark theme (AUR)
install_aur adw-gtk3-git

# Login manager — git version for Wayland stability
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
