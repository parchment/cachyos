#!/usr/bin/env bash
set -euo pipefail

IOSEVKA_VERSION="34.4.0"
FONT_NAME="Iosevka Vixelated"
FONT_MARKER="$HOME/.local/share/fonts/IosevkaVixelated-Regular.ttf"
FONT_DIR="$HOME/.local/share/fonts"
SYSTEM_FONT_DIR="/usr/share/fonts/iosevka-vixelated"
BUILD_DIR="$(mktemp -d)"
PLANS_SOURCE="${XDG_CONFIG_HOME:-$HOME/.config}/iosevka/private-build-plans.toml"

cleanup() {
    local exit_code=$?
    if [[ -d "$BUILD_DIR" ]]; then
        echo "→ Cleaning up build directory"
        rm -rf "$BUILD_DIR"
    fi
    if [[ $exit_code -ne 0 ]]; then
        echo "✗ Font build failed (exit $exit_code) — no fonts were installed"
        echo "  Re-run bootstrap after resolving the issue above"
        echo "  Build dir has been cleaned; safe to retry"
    fi
    exit $exit_code
}
trap cleanup EXIT

if fc-list | grep -q "$FONT_NAME" && [[ -f "$FONT_MARKER" ]]; then
    echo "→ $FONT_NAME already installed, skipping"
    exit 0
fi

echo "→ Building $FONT_NAME v$IOSEVKA_VERSION"

if ! command -v npm &>/dev/null; then
    echo "✗ npm not found — run 01-packages.sh first"
    exit 1
fi

if [[ ! -f "$PLANS_SOURCE" ]]; then
    echo "✗ plans.toml not found at $PLANS_SOURCE"
    echo "  Ensure ~/.config/iosevka/private-build-plans.toml is tracked in yadm"
    exit 1
fi

if ! curl -fsSL --head "https://github.com" &>/dev/null; then
    echo "✗ GitHub unreachable — check network before retrying"
    exit 1
fi

echo "→ Downloading Iosevka v$IOSEVKA_VERSION"
curl -fsSL \
    "https://github.com/be5invis/Iosevka/archive/refs/tags/v${IOSEVKA_VERSION}.tar.gz" \
    | tar -xz -C "$BUILD_DIR"

IOSEVKA_DIR="$BUILD_DIR/Iosevka-${IOSEVKA_VERSION}"

if [[ ! -d "$IOSEVKA_DIR" ]]; then
    echo "✗ Extraction failed or directory structure unexpected"
    echo "  Expected: $IOSEVKA_DIR"
    exit 1
fi

cp "$PLANS_SOURCE" "$IOSEVKA_DIR/private-build-plans.toml"

echo "→ Installing npm dependencies"
cd "$IOSEVKA_DIR"
npm ci

echo "→ Building (this takes a while)"
npm run build -- contents::IosevkaVixelated

if ! ls dist/IosevkaVixelated/TTF/*.ttf &>/dev/null; then
    echo "✗ Build completed but no TTFs found in dist/"
    echo "  Check private-build-plans.toml family name matches: IosevkaVixelated"
    exit 1
fi

# Install to user font dir
mkdir -p "$FONT_DIR"
cp -v dist/IosevkaVixelated/TTF/*.ttf "$FONT_DIR/"
fc-cache -fv "$FONT_DIR"

# Install system-wide so SDDM (runs as sddm user) can use the font
sudo mkdir -p "$SYSTEM_FONT_DIR"
sudo cp dist/IosevkaVixelated/TTF/*.ttf "$SYSTEM_FONT_DIR/"
sudo fc-cache -f "$SYSTEM_FONT_DIR"

echo "→ $FONT_NAME installed successfully"

echo "--- Layer 9 verification ---"
fc-list | grep -ic "iosevka vixelated" | xargs echo "Iosevka Vixelated variants registered:"
echo "--- Layer 9 complete ---"
