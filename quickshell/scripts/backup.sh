#!/usr/bin/env bash
# backup.sh — Backup ~/.config/quickshell to a timestamped archive

set -euo pipefail

DEST="${1:-$HOME/quickshell-backup-$(date +%Y%m%d-%H%M%S).tar.gz}"
SRC="$HOME/.config/quickshell"

[[ -d "$SRC" ]] || { echo "No config found at $SRC"; exit 1; }

tar -czf "$DEST" -C "$(dirname "$SRC")" "$(basename "$SRC")"
echo "✅ Backup saved: $DEST"
