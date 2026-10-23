#!/usr/bin/env bash
# setup.sh — Install QuickShell + Hyprland dependencies
# Usage: ./setup.sh [--dry-run]

set -euo pipefail

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

log()  { echo -e "\e[34m[INFO]\e[0m  $*"; }
ok()   { echo -e "\e[32m[OK]\e[0m    $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m  $*"; }
err()  { echo -e "\e[31m[ERROR]\e[0m $*" >&2; exit 1; }

run() {
    if $DRY_RUN; then
        echo "  (dry-run)" "$@"
    else
        "$@"
    fi
}

# ── Detect distro ─────────────────────────────────────────
if command -v pacman &>/dev/null; then
    DISTRO="arch"
elif command -v apt &>/dev/null; then
    DISTRO="debian"
else
    err "Unsupported distro. See docs/INSTALLATION.md for manual steps."
fi

log "Detected distro: $DISTRO"

# ── Arch / Manjaro ────────────────────────────────────────
if [[ "$DISTRO" == "arch" ]]; then
    PKGS=(
        quickshell
        qt6-base qt6-declarative qt6-wayland qt6-svg
        hyprland
        python-pywal
        jq
        pipewire wireplumber
        networkmanager
        bluez bluez-utils
        upower brightnessctl
        grim slurp
        playerctl
        hyprsunset
    )

    log "Installing packages via pacman…"
    run sudo pacman -S --needed --noconfirm "${PKGS[@]}"

    # AUR fallback for quickshell if not in official repos
    if ! pacman -Qi quickshell &>/dev/null; then
        warn "quickshell not found in official repos — trying AUR (yay required)"
        command -v yay &>/dev/null || err "yay not found. Install it first: https://github.com/Jguer/yay"
        run yay -S --needed --noconfirm quickshell
    fi

    ok "Arch packages installed"
fi

# ── Debian / Ubuntu ───────────────────────────────────────
if [[ "$DISTRO" == "debian" ]]; then
    warn "Debian: QuickShell must be compiled from source."
    log  "Installing build dependencies…"

    BUILD_DEPS=(
        cmake ninja-build git pkg-config
        qt6-base-dev qt6-declarative-dev
        qt6-wayland-dev
        libwayland-dev wayland-protocols
        libpipewire-0.3-dev
        libdbus-1-dev libxkbcommon-dev
        python3-pywal jq
        playerctl brightnessctl
        grim slurp
    )
    run sudo apt update
    run sudo apt install -y "${BUILD_DEPS[@]}"

    log "Cloning & building QuickShell…"
    TMP=$(mktemp -d)
    run git clone https://github.com/quickshell-mirror/quickshell.git "$TMP/quickshell"
    run cmake -B "$TMP/build" -G Ninja -S "$TMP/quickshell"
    run cmake --build "$TMP/build"
    run sudo cmake --install "$TMP/build"

    ok "QuickShell built & installed"
fi

# ── Deploy config ─────────────────────────────────────────
DEST="$HOME/.config/quickshell"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$SCRIPT_DIR" != "$DEST" ]]; then
    log "Symlinking config → $DEST"
    run ln -sfn "$SCRIPT_DIR" "$DEST"
else
    log "Config already at $DEST — skipping symlink"
fi

# ── Pywal color generation ────────────────────────────────
WALLPAPER="${HOME}/wallpaper.jpg"
if [[ -f "$WALLPAPER" ]]; then
    log "Generating color scheme from $WALLPAPER…"
    run wal -i "$WALLPAPER"
    ok "Color scheme generated"
else
    warn "No wallpaper found at $WALLPAPER. Run 'wal -i /path/to/wallpaper' manually."
fi

# ── Hyprland autostart ────────────────────────────────────
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [[ -f "$HYPR_CONF" ]]; then
    if ! grep -q "exec-once = quickshell" "$HYPR_CONF"; then
        log "Adding QuickShell to Hyprland autostart…"
        run sh -c "echo 'exec-once = quickshell' >> \"$HYPR_CONF\""
        run sh -c "echo 'source = ~/.config/quickshell/hyprland-layer-config.conf' >> \"$HYPR_CONF\""
        ok "Hyprland config updated"
    else
        log "QuickShell already in hyprland.conf — skipping"
    fi
else
    warn "hyprland.conf not found at $HYPR_CONF. Add manually:"
    warn "  exec-once = quickshell"
    warn "  source = ~/.config/quickshell/hyprland-layer-config.conf"
fi

echo ""
ok "Setup complete! Run: quickshell"
