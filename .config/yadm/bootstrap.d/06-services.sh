#!/usr/bin/env bash
set -euo pipefail

enable_svc() {
    systemctl is-enabled "$1" &>/dev/null || sudo systemctl enable --now "$1"
}

enable_user_svc() {
    systemctl --user is-enabled "$1" &>/dev/null || systemctl --user enable --now "$1"
}

# System services
enable_svc NetworkManager
enable_svc bluetooth

# TLP conflicts with power-profiles-daemon; mask it first
sudo systemctl disable --now power-profiles-daemon 2>/dev/null || true
sudo systemctl mask power-profiles-daemon 2>/dev/null || true
enable_svc tlp

enable_svc tailscaled

# Pipewire via systemd user services
enable_user_svc pipewire
enable_user_svc pipewire-pulse
enable_user_svc wireplumber

# TLP config — T480-specific overrides
TLP_CONF="/etc/tlp.conf"
if ! grep -q "START_CHARGE_THRESH_BAT0=40" "$TLP_CONF" 2>/dev/null; then
    sudo tee -a "$TLP_CONF" > /dev/null <<'EOF'

# ── T480 overrides — appended by bootstrap ──────────────────────────────────

# Battery charge thresholds (40-80 for longevity)
START_CHARGE_THRESH_BAT0=40
STOP_CHARGE_THRESH_BAT0=80
START_CHARGE_THRESH_BAT1=40
STOP_CHARGE_THRESH_BAT1=80

# USB autosuspend
USB_AUTOSUSPEND=1
USB_EXCLUDE_BTUSB=1

# CPU scaling
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
CPU_ENERGY_PERF_POLICY_ON_AC=balance_performance
CPU_ENERGY_PERF_POLICY_ON_BAT=power

# PCIe ASPM
PCIE_ASPM_ON_BAT=powersupersave

# WiFi power saving
WIFI_PWR_ON_AC=off
WIFI_PWR_ON_BAT=on

# Disable NMI watchdog on battery
NMI_WATCHDOG=0
EOF
    sudo systemctl restart tlp
fi

# Firefox must be installed before this point — tailscale up opens a browser auth URL.
# This is guaranteed by 01-packages.sh installing firefox.
# Running on bare TTY without a browser will stall here.
fish -c setup_tailscale
fish -c setup_docker

echo ""
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ MANUAL STEP REQUIRED                                            │"
echo "│                                                                 │"
echo "│ Force S3 deep sleep (better battery drain on suspend):          │"
echo "│   Edit /boot/loader/entries/cachyos.conf                        │"
echo "│   Add to options line: mem_sleep_default=deep                   │"
echo "│                                                                 │"
echo "│ Also: BIOS → Config → Power → Sleep State → Linux              │"
echo "└─────────────────────────────────────────────────────────────────┘"

echo "--- Layer 6 verification ---"
systemctl is-active NetworkManager && echo "NetworkManager: ok" || echo "NetworkManager: FAIL"
systemctl is-active bluetooth      && echo "bluetooth: ok"      || echo "bluetooth: FAIL"
systemctl is-active tlp            && echo "tlp: ok"            || echo "tlp: FAIL"
systemctl is-active tailscaled     && echo "tailscaled: ok"     || echo "tailscaled: FAIL"
echo "--- Layer 6 complete ---"
