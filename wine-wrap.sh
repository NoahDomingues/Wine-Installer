#!/usr/bin/env bash

# ========== WINE WRAPPER FOR FILE LAUNCHING ==========
# ---------------- NOAH DOMINGUES v1.0 ----------------
# -- https://github.com/NoahDomingues/Wine-Installer --

# Per-user logging wrapper for Wine. Strips stray quotes from the passed filename.
LOG="${HOME:-/root}/.cache/wine-launch.log"

# Take the first argument and strip surrounding single or double quotes if present
arg="$1"
arg="${arg#\"}"
arg="${arg#\'}"
arg="${arg%\"}"
arg="${arg%\'}"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG")"

# Log start and WINEPREFIX
echo "[$(date --iso-8601=seconds)] Starting wine with: $arg" >> "$LOG"
echo "[$(date --iso-8601=seconds)] WINEPREFIX=${WINEPREFIX:-$HOME/.wine}" >> "$LOG"

# Run wine with cleaned path and capture output
env WINEPREFIX="${WINEPREFIX:-$HOME/.wine}" /usr/bin/wine "$arg" >> "$LOG" 2>&1

# Log exit code
echo "[$(date --iso-8601=seconds)] Exit code: $?" >> "$LOG"
