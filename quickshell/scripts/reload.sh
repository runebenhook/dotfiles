#!/usr/bin/env bash
# reload.sh — Safely reload QuickShell after config changes

set -euo pipefail

log() { echo -e "\e[34m[INFO]\e[0m $*"; }
ok()  { echo -e "\e[32m[OK]\e[0m   $*"; }

# Try IPC reload first (non-destructive, keeps socket state)
if command -v quickshell &>/dev/null && quickshell ipc reload 2>/dev/null; then
    ok "Reloaded via IPC"
    exit 0
fi

# Fallback: kill & restart
log "IPC not available — restarting QuickShell…"
killall quickshell 2>/dev/null || true
sleep 0.3
nohup quickshell &>/dev/null &
ok "QuickShell restarted (PID $!)"
