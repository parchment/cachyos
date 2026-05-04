#!/usr/bin/env bash
set -euo pipefail

SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="$SDDM_CONF_DIR/sddm.conf"

sudo mkdir -p "$SDDM_CONF_DIR"

# Write config only if not already present with correct content
if ! grep -q "phinger-cursors-light" "$SDDM_CONF" 2>/dev/null; then
    sudo tee "$SDDM_CONF" > /dev/null <<'EOF'
[General]
InputMethod=

[Theme]
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
echo "--- Layer 8 complete ---"
