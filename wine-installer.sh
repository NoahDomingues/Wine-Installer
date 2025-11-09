#!/usr/bin/env bash
set -euo pipefail

# Filenames in repo
WRAPPER_SRC="./wine-wrap.sh"
DESKTOP_SRC="./wine.desktop"      # adjust if your .desktop has another name
WRAPPER_DST="/usr/local/bin/wine-wrap.sh"
DESKTOP_DST="/usr/share/applications/wine.desktop"
MIMEAPPS="/etc/xdg/mimeapps.list"
BACKUP_SUFFIX=".bak-$(date +%Y%m%d%H%M%S)"
LOG="/var/log/wine-installer.log"

log() {
  echo "[$(date --iso-8601=seconds)] $*" | tee -a "$LOG"
}

require_files() {
  if [[ ! -f "$WRAPPER_SRC" || ! -f "$DESKTOP_SRC" ]]; then
    echo "Error: expected to find $WRAPPER_SRC and $DESKTOP_SRC in current directory."
    exit 2
  fi
}

ensure_sudo_available() {
  if ! command -v sudo >/dev/null 2>&1; then
    echo "This installer requires sudo; please run as root if sudo is not available."
    exit 3
  fi
}

install_packages() {
  local pkgs=()
  if ! command -v wine >/dev/null 2>&1; then
    log "Wine not found; scheduling installation"
    sudo dpkg --add-architecture i386 || true
    sudo apt-get update -y
    pkgs+=(wine64 wine32)
  else
    log "wine detected at $(command -v wine)"
  fi

  if ! command -v winetricks >/dev/null 2>&1; then
    log "winetricks not found; scheduling installation"
    pkgs+=(winetricks)
  else
    log "winetricks detected at $(command -v winetricks)"
  fi

  if [ ${#pkgs[@]} -gt 0 ]; then
    log "Installing packages: ${pkgs[*]}"
    sudo apt-get install -y "${pkgs[@]}"
  else
    log "No package installation required"
  fi
}

# Initialize Wine prefix in a safe, non-GUI way first.
initialize_wine() {
  if ! command -v wine >/dev/null 2>&1; then
    log "wine not installed; skipping initialization"
    return
  fi

  # Determine the real user to run wine commands as
  local run_as_user="${SUDO_USER:-$(whoami)}"
  log "Initializing Wine prefix for user: $run_as_user"

  # Ensure HOME for the target user is available
  local user_home
  user_home="$(getent passwd "$run_as_user" | cut -d: -f6 || echo "$HOME")"

  # Run wineboot to create ~/.wine (non-GUI)
  if [ "$run_as_user" = "root" ]; then
    log "Running wineboot as root (non-GUI)"
    wineboot --init || true
  else
    log "Running wineboot as $run_as_user (non-GUI)"
    sudo -H -u "$run_as_user" bash -lc 'wineboot --init || true'
  fi

  # If DISPLAY is set and we are not root, run winecfg interactively (optional)
  if [ -n "${DISPLAY:-}" ] && [ "$run_as_user" != "root" ]; then
    log "DISPLAY detected; launching winecfg for $run_as_user (user may need to interact with GUI)"
    sudo -H -u "$run_as_user" bash -lc 'if command -v winecfg >/dev/null 2>&1; then winecfg || true; fi'
  else
    log "Skipping interactive winecfg (no DISPLAY or running as root)."
  fi
}

install_wrapper() {
  log "Installing wrapper to $WRAPPER_DST"
  sudo mkdir -p "$(dirname "$WRAPPER_DST")"
  sudo cp --preserve=mode,ownership,timestamps "$WRAPPER_SRC" "$WRAPPER_DST"
  sudo chmod 755 "$WRAPPER_DST"
  log "Wrapper installed"
}

install_desktop() {
  log "Installing desktop file to $DESKTOP_DST"
  sudo mkdir -p "$(dirname "$DESKTOP_DST")"
  sudo cp --preserve=mode,ownership,timestamps "$DESKTOP_SRC" "$DESKTOP_DST"
  sudo chmod 644 "$DESKTOP_DST"
  if command -v update-desktop-database >/dev/null 2>&1; then
    log "Updating desktop database"
    sudo update-desktop-database /usr/share/applications || true
  else
    log "update-desktop-database not present; skipping"
  fi
}

install_mime_defaults() {
  if [ ! -f "$MIMEAPPS" ]; then
    log "$MIMEAPPS not present; creating"
    sudo touch "$MIMEAPPS"
    sudo chmod 644 "$MIMEAPPS"
  fi

  # If already present with wine.desktop, skip
  if grep -q -F "application/x-ms-dos-executable=wine.desktop" "$MIMEAPPS" \
     || grep -q -F "application/x-msdownload=wine.desktop" "$MIMEAPPS"; then
    log "MIME defaults already configured"
    return
  fi

  log "Backing up $MIMEAPPS to ${MIMEAPPS}${BACKUP_SUFFIX}"
  sudo cp "$MIMEAPPS" "${MIMEAPPS}${BACKUP_SUFFIX}"

  log "Appending system defaults"
  sudo bash -c "cat >> '$MIMEAPPS' <<'EOF'

[Default Applications]
application/x-ms-dos-executable=wine.desktop
application/x-msdownload=wine.desktop
EOF"
  log "MIME defaults appended"
}

post_install_notes() {
  cat <<'NOTE' | sed 's/^/  /'
Note:
- File managers may still use per-user settings in ~/.config/mimeapps.list which override system defaults.
- Make sure .exe files are marked executable (chmod +x /path/to/file.exe) so file managers treat them as runnable.
- If winecfg GUI was launched, the user may need to finish any first-run prompts.
NOTE
}

main() {
  require_files
  ensure_sudo_available
  log "Starting installer"

  install_packages

  # initialize wine prefix for the invoking user (wineboot + optional winecfg)
  initialize_wine

  install_wrapper
  install_desktop
  install_mime_defaults

  log "Installation complete"
  post_install_notes
}

main "$@"
