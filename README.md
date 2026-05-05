# dotfiles

A minimal, keyboard-first Hyprland desktop on a ThinkPad T480.
Not a ricing project. Not a showcase. A defined endstate, built once, maintained like infrastructure.

---

## Philosophy

- **No chrome that isn't earning its place.** Every visible element must justify its presence.
- **Keyboard-first, always.** The mouse exists for browsers and design tools, not the environment.
- **Defined scope.** The component list is closed. Additions require deliberate justification, not impulse.
- **Maintain like infrastructure.** Update deliberately, fix what breaks, move on.
- **Desktop as instrument panel.** System state lives on the desktop, revealed on demand — not permanently consuming screen real estate.

---

## Hardware

ThinkPad T480 — i7-8650U, 64GB DDR4, 2TB NVMe, dual hot-swappable batteries.
Last ThinkPad with full upgradeability. Treated as a mobile workstation, not a thin client.

---

## Component List

| Role | Tool | Notes |
|---|---|---|
| Compositor | Hyprland | Dynamic tiling, scrollable workspace tape |
| Desktop widgets | Quickshell | Rendered behind windows, always present |
| Notifications | mako | Minimal, keyboard-dismissible |
| Lock screen | hyprlock | Simple, no flourishes |
| Idle handler | hypridle | Screen off → suspend |
| Terminal | Ghostty | Primary interface, explicit fish shell |
| Browser | Firefox | Only GUI-heavy app |
| Editor | Helix | Modal, LSP-native |
| File manager | yazi | TUI, keyboard-driven |
| Git TUI | lazygit | Terminal UI for git |
| Bluetooth | bluetuith | TUI, opened on demand |
| Keyring | gnome-keyring | SSH, git, browser secrets via libsecret |
| Media keys | playerctl | Bound in Hyprland config |
| Network | NetworkManager + nmcli | Daemon only, no GUI |
| Mesh VPN | Tailscale | Daemon only, SSH-enabled |
| Login manager | SDDM (git) | PAM integration for gnome-keyring unlock |
| Shell | Fish | conf.d modular config, Hydro prompt |
| Dotfiles | yadm | Bootstrap via `~/.config/yadm/bootstrap.d/` |

No app launcher. No status bar. No dock. No file manager GUI. No Bluetooth GUI.

---

## Repository Layout

```
~/.config/
├── cargo/
│   └── config.toml              # Private mini-registry
├── fish/
│   ├── config.fish              # Minimal: fisher init, zoxide (must be ordered)
│   ├── fish_plugins             # Fisher manifest
│   ├── conf.d/
│   │   ├── aliases.fish         # All abbr declarations
│   │   ├── env.fish             # set -gx declarations, PATH
│   │   ├── keybinds.fish        # Atuin history search bindings
│   │   ├── prompt.fish          # Hydro prompt config
│   │   └── wayland.fish         # MOZ_ENABLE_WAYLAND, ELECTRON hint
│   └── functions/
│       ├── setup_docker.fish
│       └── setup_tailscale.fish
├── ghostty/
│   └── config                   # Palette source of truth for entire system
├── git/
│   ├── config                   # Aliases, GPG signing, LFS, libsecret credential helper
│   └── ignore                   # Global gitignore (auto-discovered by git)
├── helix/
│   ├── config.toml
│   ├── languages.toml
│   └── themes/
│       └── vixelated.toml       # References ANSI colours — inherits from Ghostty palette
├── hypr/
│   ├── hyprland.conf
│   ├── hyprlock.conf
│   └── hypridle.conf
├── mako/
│   └── config
├── quickshell/
│   ├── Shell.qml
│   └── DesktopWidgets.qml
└── yadm/
    ├── bootstrap                # Entry point
    ├── bootstrap.d/
    │   ├── 00-aur.sh            # paru (AUR helper) — must run first
    │   ├── 01-packages.sh       # pacman packages
    │   ├── 02-aur-packages.sh   # AUR packages via paru
    │   ├── 03-tools.sh          # lazygit, yazi, rustup, pnpm
    │   ├── 04-shell.sh          # Fish as default shell, fisher + plugins
    │   ├── 05-hyprland.sh       # Config dir, cursor theme
    │   ├── 06-services.sh       # systemd services, TLP config, Tailscale
    │   ├── 07-keyring.sh        # PAM integration for gnome-keyring + SDDM
    │   └── 08-sddm.sh           # SDDM config, enable service
    └── ignore
~/.gnupg/
└── gpg-agent.conf               # TTL config, no SSH support (handled by gnome-keyring)
```

---

## Bootstrap

Fresh machine setup. Run after `yadm clone`.

```bash
# Prerequisites
# 1. CachyOS installed, logged in as your user
# 2. Network connected
# 3. yadm cloned: yadm clone <repo-url>

~/.config/yadm/bootstrap
```

### What the bootstrap does

```
00-aur.sh       Installs paru from AUR via makepkg — prerequisite for all AUR installs
01-packages.sh  pacman packages: compositor stack, terminal, editor, audio, network
02-aur-packages AUR packages: sddm-git, phinger-cursors, quickshell, bluetuith, grimblast-git
03-tools.sh     lazygit, yazi, rustup stable, pnpm via npm
04-shell.sh     Sets fish as default shell, installs fisher + plugins from fish_plugins manifest
05-hyprland.sh  Ensures hypr config dir exists, writes cursor index.theme
06-services.sh  Enables NetworkManager, bluetooth, tlp, tailscaled, pipewire user services
                Appends T480-specific TLP overrides to /etc/tlp.conf
                Runs setup_tailscale — opens browser auth URL (Firefox must be installed)
07-keyring.sh   Appends pam_gnome_keyring lines to /etc/pam.d/sddm
08-sddm.sh      Writes /etc/sddm.conf.d/sddm.conf, enables sddm service
```

### Idempotency

Every bootstrap script is safe to run multiple times. Re-running the full bootstrap after a partial failure is always safe.

### Manual steps (cannot be automated)

Two steps require manual intervention and are surfaced as banners during bootstrap:

**S3 sleep state** — must be set in both BIOS and bootloader:
```
BIOS → Config → Power → Sleep State → Linux
```
```bash
# /boot/loader/entries/cachyos.conf — add to options line:
mem_sleep_default=deep

# Verify after reboot:
cat /sys/power/mem_sleep   # should show: s2idle [deep]
```

**SSH keys** — not stored in yadm, must be generated or imported manually:
```bash
# Generate
ssh-keygen -t ed25519 -C "hello@vparchment.dev"

# Or import from backup
cp <key> ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519
```

---

## Compositor: Hyprland

### Workspace model

Workspaces created dynamically, destroyed when empty. No persistent empty workspaces.
Scrollable tape — workspaces exist on a horizontal continuum. Navigate with `SUPER+H/L` or 3-finger swipe.
Direct jump to numbered workspaces with `SUPER+1-5`.

### Window model

Tiling by default. Floating available. All navigation by keyboard. No title bars, no animations, no blur.

### Environment variables

Set in `hyprland.conf` so they apply to all child processes regardless of launch method.
`MOZ_ENABLE_WAYLAND` and `ELECTRON_OZONE_PLATFORM_HINT` are also set in `conf.d/wayland.fish` — intentional redundancy that closes the gap between GUI-launched and terminal-launched apps.

### Startup order

`gnome-keyring-daemon` must be first — all subsequent apps that need secrets depend on the socket existing. Everything else is order-independent. Pipewire is managed via systemd user services, not `exec-once`.

---

## Keybinds

`SUPER` is the primary modifier. No app launcher — apps have keybinds.

### Workspace

| Bind | Action |
|---|---|
| `SUPER + H / ←` | Previous workspace |
| `SUPER + L / →` | Next workspace |
| `SUPER + 1-5` | Jump to workspace |
| `SUPER + SHIFT + 1-5` | Send window to workspace |
| 3-finger swipe | Scroll workspace tape |

### Windows

| Bind | Action |
|---|---|
| `SUPER + h/j/k/l` | Focus window |
| `SUPER + SHIFT + h/j/k/l` | Move window |
| `SUPER + F` | Toggle float |
| `SUPER + M` | Maximise (keeps gaps) |
| `SUPER + SHIFT + M` | True fullscreen |
| `SUPER + Q` | Kill window |

### Applications

| Bind | Action |
|---|---|
| `SUPER + Return` | Ghostty |
| `SUPER + B` | Firefox |
| `SUPER + Y` | yazi (in Ghostty) |
| `SUPER + T` | bluetuith (in Ghostty) |
| `SUPER + E` | Helix in `~/Documents` |
| `SUPER + K` | lazydocker |
| `SUPER + D` | Toggle desktop (fade all windows, consume keypresses until `ESC` or `SUPER+D`) |

### Session

| Bind | Action |
|---|---|
| `SUPER + SHIFT + L` | Lock (hyprlock) |
| `SUPER + SHIFT + S` | Suspend |
| `SUPER + SHIFT + E` | Exit Hyprland |

### Media & function keys

Volume, playback, brightness, and screenshot are all bound to their respective hardware keys via `bindel`/`bindl`.

---

## Colour Palette

The Ghostty config is the **single source of truth** for all colours. Helix, mako, hyprlock, and Quickshell all derive from this palette. Changing a colour means editing the Ghostty config only.

### Base palette

```
0  #000000   black    — desktop background
1  #ff6188   red      — critical states, tailscale off, battery critical
2  #a9dc76   green    — healthy states, charging, tailscale on
3  #ffd866   yellow   — strings, warnings (reserved for widgets)
4  #78b4f3   blue     — CPU bar filled
5  #fc9867   magenta  — (reserved)
6  #ab9df2   cyan     — RAM bar filled
7  #ffffff   white    — clock time, primary labels
```

### Bright palette (bold text differentiation)

```
8  #1a1a1a   bright black
9  #ff92a8   bright red
10 #c3f09a   bright green
11 #ffe599   bright yellow
12 #a8d0ff   bright blue
13 #ffb899   bright magenta
14 #c8bdff   bright cyan
15 #ffffff   bright white
```

### Dim variants (widget empty bars, secondary text)

```
dim-blue    #3a5573   CPU bar empty
dim-cyan    #524a73   RAM bar empty
dim-white   #444444   labels, percentages, date line
```

### Colour assignments

| Element | Colour |
|---|---|
| Desktop background | `#000000` |
| Ghostty background | `#000000` |
| Ghostty background opacity | `0.95` |
| Clock — time | `#ffffff` |
| Clock — date | `#444444` |
| CPU bar filled | `#78b4f3` |
| CPU bar empty | `#3a5573` |
| RAM bar filled | `#ab9df2` |
| RAM bar empty | `#524a73` |
| Battery (normal + charging) | `#a9dc76` |
| Battery (critical ≤15%) | `#ff6188` |
| Tailscale connected | `#a9dc76` |
| Tailscale disconnected | `#ff6188` |
| mako critical border | `#ff6188` |

---

## Typography

**JetBrains Mono** (Nerd Font variant) — installed via `pacman -S ttf-jetbrains-mono-nerd`.

Used system-wide: Ghostty, Helix, mako, hyprlock, Quickshell widgets, SDDM.

---

## Desktop Widgets: Quickshell

Renders on the desktop layer behind all windows. Always present, revealed via `SUPER+D` or when the current workspace has no windows.

### Layout

```
┌─────────────────────────────────────────────────┐
│                                        12:47    │
│                                   Mon · 3 May   │
│                                                 │
│                                                 │
│                                                 │
│                                                 │
│                                                 │
│  CPU  ████████░░░░  52%     ◈ tailscale         │
│  RAM  █████░░░░░░░  31%     ▼ wlan0  ████  87%  │
│                             ▮ INT  ████████ 78% │
│                             ▮ EXT  ████░░░░ 43% │
└─────────────────────────────────────────────────┘
```

- **Top-right**: clock. Time at ~2.5× body size (`#ffffff`), date line smaller (`#444444`), middle dot separator.
- **Bottom-left**: CPU and RAM stacked. Condensed labels, 8-char block bars, percentage.
- **Bottom-right**: Tailscale indicator, network connection + signal bar, INT and EXT battery bars.
- **Centre**: intentionally empty.

EXT battery row is hidden (`visible: false`) when BAT1 is not present — handles single-battery state during hot-swap.

Bar characters: `█` (filled) and `░` (empty) — block characters, consistent with monospace font.

Data refresh: every 3 seconds via `Process` runners reading `/proc/stat`, `/proc/meminfo`, `/sys/class/power_supply/`, and `nmcli`/`tailscale status`.

---

## Helix

Colour coupling: `vixelated.toml` references ANSI colour names (`"red"`, `"green"` etc.) which resolve to whatever the terminal declares them to be. Since Ghostty's palette is the source of truth, Helix colours are always in sync — updating the Ghostty palette automatically updates the Helix theme. No dual maintenance.

LSP + formatters required in PATH:
- `typescript-language-server` — JS/TS/JSX/TSX
- `rust-analyzer` — Rust (installed via rustup)
- `prettier` — HTML, JS, TS, JSON, YAML (via pnpm)
- `taplo` — TOML (via cargo)

---

## Fish Shell

### Config structure

`config.fish` is minimal — only things that must be ordered or are init-only:
- Greeting suppression
- `zoxide init` — must follow PATH setup, so lives here not in `conf.d/`
- Fisher init + `fisher update` — runs on every shell start to keep plugins in sync with `fish_plugins`

Everything else is split across `conf.d/` for modularity:

| File | Contents |
|---|---|
| `env.fish` | All `set -gx` declarations, PATH additions, SSH_AUTH_SOCK |
| `wayland.fish` | `MOZ_ENABLE_WAYLAND`, `ELECTRON_OZONE_PLATFORM_HINT` |
| `prompt.fish` | Hydro prompt colours and symbols |
| `keybinds.fish` | Atuin history search on `Ctrl+R` and `↑` |
| `aliases.fish` | All `abbr` declarations |

### Key abbreviations

```
hx / e    helix
g         git
lg        lazygit
d         docker
dc        docker compose
wl        nmcli device wifi list
syu       sudo pacman -Syu
pss       paru -Ss
psi       paru -S
```

### Functions

`setup_tailscale` and `setup_docker` are idempotent Fish functions in `~/.config/fish/functions/`. Called during bootstrap and available interactively.

---

## Git

Config at `~/.config/git/config`. Global ignore at `~/.config/git/ignore` — auto-discovered by git, no `excludesfile` config needed.

GPG commit signing enabled. Credential helper is `git-credential-libsecret` which bridges to gnome-keyring — credentials stored once, retrieved silently thereafter.

Verify GPG signing is working:
```bash
echo "test" | gpg --clearsign
```

`~/.gnupg/gpg-agent.conf` sets cache TTLs only. SSH support is explicitly not enabled here — SSH agent is handled by gnome-keyring separately.

### Cargo private registry

`~/.cargo/config.toml` configures a private mini-registry at `mini-registry.fly.dev`. Credential stored via `cargo:token` provider.

---

## Keyring: gnome-keyring

Covers SSH keys, git credentials (via libsecret + git-credential-libsecret), and browser secrets.

Two mechanisms work together:
1. **PAM** (`/etc/pam.d/sddm`) — unlocks the keyring at login automatically
2. **exec-once** (`hyprland.conf`) — starts the daemon so the socket exists for child processes

Both are required. PAM unlocks, exec-once starts the daemon. The socket lives at `$XDG_RUNTIME_DIR/keyring/ssh`.

`SSH_AUTH_SOCK` is exported in `conf.d/env.fish` to point Fish-launched processes at the correct socket.

---

## Bluetooth: bluetuith

TUI only. Opened with `SUPER+T` (Ghostty running bluetuith). No applet, no system tray.
`bluetooth.service` is enabled as a system service by `06-services.sh`.

---

## Network: NetworkManager

`nmcli` only. `conf.d/aliases.fish` provides `wl`, `wc`, `ns` abbreviations for common operations. No GUI applet.

---

## Tailscale

`tailscaled` is enabled as a system service. `setup_tailscale` runs `tailscale up --ssh` which enables Tailscale SSH — allows access to this machine from other devices on the tailnet.

First-run auth opens a browser URL. Firefox must be installed before `06-services.sh` runs — it is, via `01-packages.sh`.

Auth state persists across reboots. Re-running `setup_tailscale` is safe and idempotent.

---

## SDDM

Using `sddm-git` from AUR — stable SDDM has known Wayland compositor issues.

Config at `/etc/sddm.conf.d/sddm.conf`. PAM integration in `/etc/pam.d/sddm` enables automatic keyring unlock at login.

---

## T480: Power Management

### TLP

T480-specific overrides appended to `/etc/tlp.conf` by `06-services.sh`:

- Charge thresholds: 40% start / 80% stop on both batteries — longevity range
- CPU governor: performance on AC, powersave on battery
- WiFi power saving: off on AC, on on battery
- BT excluded from USB autosuspend

Override thresholds temporarily before travel:
```bash
sudo tlp setcharge BAT0 40 100
sudo tlp setcharge BAT1 40 100
```

Reset to configured thresholds:
```bash
sudo tlp setcharge BAT0
sudo tlp setcharge BAT1
```

Check battery state:
```bash
tlp-stat -b
```

### Dual battery hot-swap

The T480 external battery can be swapped while running on internal — the system does not suspend. TLP handles the transition automatically. BAT1 presence is detected by Quickshell widgets which hide the EXT battery row when absent.

### S3 sleep state

T480 defaults to `s2idle` which drains 5-10% overnight. Force S3 deep sleep:

```
BIOS → Config → Power → Sleep State → Linux
```

```bash
# /boot/loader/entries/cachyos.conf — add to options line
mem_sleep_default=deep
```

Verify:
```bash
cat /sys/power/mem_sleep   # bracketed value is active: s2idle [deep]
```

This is a manual step — surfaced as a banner during `06-services.sh`.

---

## Multi-Monitor

```ini
# hyprland.conf
monitor = eDP-1,    1920x1080@60, 0x0,    1   # Internal
monitor = HDMI-A-1, preferred,    1920x0,  1   # External right
monitor = ,preferred,auto,1                    # Fallback: any connected monitor
```

Discover connected monitor names: `hyprctl monitors`

Workspace pinning (optional):
```ini
workspace = 1, monitor:eDP-1
workspace = 2, monitor:HDMI-A-1
```

Left unpinned by default — dynamic is more flexible for a laptop.

---

---

## Cursor

Phinger cursors, light variant on dark desktop for clear contrast. Size 24.
System cursor pointed at `phinger-cursors-light` via `~/.local/share/icons/default/index.theme`.

---

## Boot Sequence

```
Power on
  └── UEFI → systemd-boot → CachyOS kernel → systemd
        ├── NetworkManager.service
        ├── tailscaled.service
        ├── bluetooth.service
        ├── tlp.service
        └── sddm.service (Wayland)
              └── PAM authentication
                    ├── pam_gnome_keyring.so → unlocks keyring
                    └── Hyprland session
                          └── hyprland.conf exec-once (in order)
                                ├── gnome-keyring-daemon  ← must be first
                                ├── quickshell
                                ├── mako
                                ├── hypridle
                                └── wl-paste --watch cliphist store

Pipewire stack managed separately via systemd user services:
  pipewire.service + pipewire-pulse.service + wireplumber.service
```

---

## Update Strategy

Update on a schedule, not reactively.

1. Read Hyprland changelogs before updating — config key renames are the most common breakage
2. `sudo pacman -Syu` (or `paru -Syu`)
3. Reboot, check the one thing that broke
4. Fix it — `yadm diff` shows what changed, `yadm checkout` rolls back a config
5. Move on

`downgrade` (AUR) is useful for pinning a package temporarily while waiting for an upstream fix.

---

## What This Is Not

- Not a showcase. Animations off. Blur off. Rounded corners minimal.
- Not extensible by default. The component list is closed. New additions need a reason.
- Not a launcher setup. Apps have keybinds. There is no fuzzy finder for the environment.
- Not a ricing project. The endstate is here. When it's built, it's done.