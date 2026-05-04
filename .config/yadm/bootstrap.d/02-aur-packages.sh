#!/usr/bin/env bash
set -euo pipefail

install_aur() {
    paru -Q "$1" &>/dev/null || paru -S --noconfirm --needed "$1"
}

# Cursor
install_aur quickshell

# Bluetooth TUI
install_aur bluetuith

# Screenshot
install_aur grimblast-git

echo "--- Layer 2 verification ---"
paru -Q phinger-cursors
echo "--- Layer 2 complete ---"
