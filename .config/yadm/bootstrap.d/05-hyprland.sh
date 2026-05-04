#!/usr/bin/env bash
set -euo pipefail

# Ensure hypr config dir exists (yadm clone places files, but dir may be missing)
mkdir -p "$HOME/.config/hypr"

# Cursor theme — points system cursor to phinger-cursors-light
CURSOR_DIR="$HOME/.local/share/icons/default"
mkdir -p "$CURSOR_DIR"
if [[ ! -f "$CURSOR_DIR/index.theme" ]]; then
    cat > "$CURSOR_DIR/index.theme" <<'EOF'
[Icon Theme]
Inherits=phinger-cursors-light
EOF
fi

echo "--- Layer 5 verification ---"
[[ -f "$HOME/.config/hypr/hyprland.conf" ]] && echo "hyprland.conf: ok" || echo "hyprland.conf: MISSING"
[[ -f "$HOME/.config/hypr/hyprlock.conf" ]] && echo "hyprlock.conf: ok"  || echo "hyprlock.conf: MISSING"
[[ -f "$HOME/.config/hypr/hypridle.conf" ]] && echo "hypridle.conf: ok"  || echo "hypridle.conf: MISSING"
[[ -f "$CURSOR_DIR/index.theme" ]]           && echo "cursor theme: ok"   || echo "cursor theme: MISSING"
echo "--- Layer 5 complete ---"
