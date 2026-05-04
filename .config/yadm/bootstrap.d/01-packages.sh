#!/usr/bin/env bash
set -euo pipefail

install_pkg() {
    pacman -Q "$1" &>/dev/null || sudo pacman -S --noconfirm --needed "$1"
}

# Compositor stack
install_pkg hyprland
install_pkg hyprlock
install_pkg hypridle
install_pkg hyprpaper

# Notifications
install_pkg mako

# Terminal
install_pkg ghostty

# Editor
install_pkg helix

# Bluetooth
install_pkg bluez
install_pkg bluez-utils

# Keyring
install_pkg gnome-keyring
install_pkg libsecret

# Audio
install_pkg pipewire
install_pkg pipewire-pulse
install_pkg wireplumber
install_pkg playerctl

# Brightness
install_pkg brightnessctl

# Browser
install_pkg firefox

# Login manager
install_pkg sddm

# Network
install_pkg networkmanager
install_pkg tailscale

# Power management
install_pkg tlp
install_pkg tlp-rdw

# Shell utilities
install_pkg fish
install_pkg atuin
install_pkg zoxide
install_pkg fzf
install_pkg fd
install_pkg jq

# JS/TS toolchain
install_pkg nodejs
install_pkg npm

# Rust toolchain
for pkg in rust rust-src; do
    sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
done
install_pkg rustup

# Clipboard
install_pkg cliphist
install_pkg wl-clipboard

# Dotfiles + git
install_pkg yadm
install_pkg git-lfs

echo "--- Layer 1 verification ---"
hyprctl --version 2>/dev/null || echo "hyprland: installed (not running)"
fish --version
node --version
echo "--- Layer 1 complete ---"
