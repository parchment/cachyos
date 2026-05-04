# Wayland-specific env vars for terminal-launched apps.
# Compositor-level env vars (hyprland.conf) cover GUI-launched apps.
# Both are set intentionally — the redundancy closes the gap.
set -gx MOZ_ENABLE_WAYLAND 1
set -gx ELECTRON_OZONE_PLATFORM_HINT wayland
