#!/usr/bin/env bash
set -euo pipefail

SDDM_CONF="/etc/sddm.conf"
SDDM_THEME_SRC="$HOME/.local/share/sddm/themes/vixelated"
SDDM_THEME_DEST="/usr/share/sddm/themes/vixelated"

# Deploy theme
sudo mkdir -p "$SDDM_THEME_DEST"
sudo cp -r "$SDDM_THEME_SRC/." "$SDDM_THEME_DEST/"
echo "→ Deployed theme to $SDDM_THEME_DEST"

# Write config only if not already present with correct content
if ! grep -q "Current=vixelated" "$SDDM_CONF" 2>/dev/null; then
    sudo tee "$SDDM_CONF" > /dev/null <<'EOF'
[General]
InputMethod=

[Theme]
Current=vixelated
CursorTheme=phinger-cursors-light

[Users]
MaximumUid=60000
MinimumUid=1000
RememberLastUser=true
RememberLastSession=true

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts
EOF
    echo "→ Wrote $SDDM_CONF"
else
    echo "→ $SDDM_CONF already configured, skipping"
fi

systemctl is-enabled sddm &>/dev/null || sudo systemctl enable sddm

echo "--- Layer 8 verification ---"
systemctl is-enabled sddm && echo "sddm: enabled" || echo "sddm: FAIL"
[[ -f "$SDDM_CONF" ]] && echo "sddm.conf: ok" || echo "sddm.conf: MISSING"
[[ -d "$SDDM_THEME_DEST" ]] && echo "vixelated theme: ok" || echo "vixelated theme: MISSING"
echo "--- Layer 8 complete ---"
