#!/usr/bin/env bash
set -euo pipefail

install_pkg() {
    pacman -Q "$1" &>/dev/null || sudo pacman -S --noconfirm --needed "$1"
}

install_pkg lazygit
install_pkg yazi

# Rust stable toolchain
rustup default stable 2>/dev/null || true

# pnpm via npm
if ! command -v pnpm &>/dev/null; then
    npm install -g pnpm
fi

echo "--- Layer 3 verification ---"
rustup show | grep "active toolchain"
cargo --version
node --version
pnpm --version
lazygit --version
echo "--- Layer 3 complete ---"
