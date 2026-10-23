#!/usr/bin/env bash
# wal-gen.sh — Generate color scheme from wallpaper, export a debug QML
# snapshot, and reload QuickShell.
#
# Usage: ./wal-gen.sh /path/to/wallpaper.jpg
#
# Note: ColorScheme.qml (config/) auto-detects ~/.cache/wal/colors.json
# and applies it live without needing a reload. The reload here is a
# convenience/fallback for the static fallback palette and other
# settings that are not hot-reloaded.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WALLPAPER="${1:-$HOME/wallpaper.jpg}"

[[ -f "$WALLPAPER" ]] || { echo "Usage: $0 /path/to/wallpaper"; exit 1; }

echo "🎨 Generating colors from: $WALLPAPER"
wal -i "$WALLPAPER" --saturate 0.7

# Export a human-readable QML snapshot of the current palette (debug/reference).
# ColorScheme.qml does NOT depend on this file — it reads colors.json directly.
if command -v jq &>/dev/null; then
    echo "📄 Exporting debug snapshot to config/ColorsWal.qml…"
    "$SCRIPT_DIR/wal-to-qml.sh" || echo "⚠️  Snapshot export skipped (non-fatal)"
else
    echo "⚠️  jq not found — skipping ColorsWal.qml snapshot (ColorScheme still works)"
fi

echo "🔄 Reloading QuickShell…"
"$SCRIPT_DIR/reload.sh"

echo "✅ Done — ColorScheme will pick up the new palette within ~2s automatically"
