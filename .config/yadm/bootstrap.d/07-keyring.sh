#!/usr/bin/env bash
set -euo pipefail

PAM_FILE="/etc/pam.d/sddm"

# Append gnome-keyring PAM lines if not already present
if ! grep -q "pam_gnome_keyring" "$PAM_FILE" 2>/dev/null; then
    sudo tee -a "$PAM_FILE" > /dev/null <<'EOF'
auth     optional  pam_gnome_keyring.so
session  optional  pam_gnome_keyring.so auto_start
EOF
    echo "→ Added gnome-keyring PAM lines to $PAM_FILE"
else
    echo "→ gnome-keyring PAM lines already present, skipping"
fi

echo ""
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ MANUAL STEP REQUIRED (if not already done)                      │"
echo "│                                                                  │"
echo "│ SSH key setup:                                                   │"
echo "│   Generate: ssh-keygen -t ed25519 -C \"hello@vparchment.dev\"    │"
echo "│   Or import: cp <key> ~/.ssh/id_ed25519 && chmod 600            │"
echo "│   Add to agent: ssh-add ~/.ssh/id_ed25519                       │"
echo "│                                                                  │"
echo "│ SSH keys are NOT stored in yadm. Keep an encrypted backup.      │"
echo "└─────────────────────────────────────────────────────────────────┘"

echo "--- Layer 7 verification ---"
grep -q "pam_gnome_keyring" "$PAM_FILE" && echo "PAM keyring: ok" || echo "PAM keyring: FAIL"
echo "--- Layer 7 complete ---"
