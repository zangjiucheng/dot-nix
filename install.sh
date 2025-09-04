#!/usr/bin/env bash
# install.sh — Install notestyle .sty files into your local texmf tree
# Works on macOS (MacTeX) and Linux (TeX Live/MiKTeX).
# Usage:
#   bash install.sh                 # install *.sty in current dir (or notestyle-modular.zip if present)
#   bash install.sh --prefix DIR    # install into DIR instead of auto TEXMFHOME
#   bash install.sh --uninstall     # remove installed notestyle directory
#   bash install.sh --dry-run       # show what would happen
#   bash install.sh --help
#
# Notes:
# - Default install target:
#     macOS (MacTeX):  ~/Library/texmf/tex/latex/notestyle/
#     Linux (TeX Live): ~/texmf/tex/latex/notestyle/
# - The script prefers notestyle-modular.zip if found, otherwise copies all *.sty in the current directory.

set -euo pipefail

DRYRUN=0
UNINSTALL=0
PREFIX=""
PKGDIR="notestyle"
SRC_ZIP="notestyle-modular.zip"

log() { echo "[*] $*"; }
warn() { echo "[!] $*" >&2; }
die() { echo "[x] $*" >&2; exit 1; }
run() { [[ "$DRYRUN" -eq 1 ]] && echo "DRYRUN: $*" || eval "$@"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRYRUN=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --prefix) PREFIX="${2:-}"; [[ -z "${PREFIX}" ]] && die "--prefix needs a directory"; shift 2 ;;
    --help|-h) grep '^# ' "$0" | sed 's/^# //'; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

OS="$(uname -s || true)"
case "$OS" in
  Darwin) default_texmfhome="$HOME/Library/texmf" ;;
  Linux)  default_texmfhome="$HOME/texmf" ;;
  *) default_texmfhome="$HOME/texmf" ;;
esac

# If kpsewhich is available, prefer its TEXMFHOME value
if command -v kpsewhich >/dev/null 2>&1; then
  kp_home="$(kpsewhich -var-value=TEXMFHOME 2>/dev/null || true)"
  if [[ -n "${kp_home:-}" ]]; then
    default_texmfhome="$kp_home"
  fi
fi

TEXMFHOME="${PREFIX:-$default_texmfhome}"
TARGET="$TEXMFHOME/tex/latex/$PKGDIR"

if [[ "$UNINSTALL" -eq 1 ]]; then
  if [[ -d "$TARGET" ]]; then
    log "Removing $TARGET"
    run "rm -rf \"$TARGET\""
  else
    warn "Nothing to remove at $TARGET"
  fi
else
  log "Installing to: $TARGET"
  run "mkdir -p \"$TARGET\""

  if [[ -f "$SRC_ZIP" ]]; then
    log "Found $SRC_ZIP — extracting into $TARGET"
    if [[ "$DRYRUN" -eq 1 ]]; then
      echo "DRYRUN: unzip -o \"$SRC_ZIP\" -d \"$TARGET\""
    else
      unzip -o "$SRC_ZIP" -d "$TARGET" >/dev/null
    fi
  else
    count=$(ls *.sty 2>/dev/null | wc -l | tr -d ' ')
    [[ "$count" -gt 0 ]] || die "No .sty files here and $SRC_ZIP not present."
    log "Copying $(ls *.sty | wc -w) .sty file(s) to $TARGET"
    run "cp -f *.sty \"$TARGET/\""
  fi
fi

# Refresh ONLY the user tree to avoid permission errors
refresh_user_db() {
  if command -v mktexlsr >/dev/null 2>&1; then
    log "Refreshing filename database for TEXMFHOME: $TEXMFHOME"
    run "mktexlsr \"$TEXMFHOME\""
  elif command -v texhash >/dev/null 2>&1; then
    log "Refreshing filename database for TEXMFHOME with texhash: $TEXMFHOME"
    run "texhash \"$TEXMFHOME\""
  elif command -v initexmf >/dev/null 2>&1; then
    # MiKTeX fallback; usually Windows, but keep for completeness
    log "Refreshing filename database with initexmf --update-fndb"
    run "initexmf --update-fndb"
  else
    warn "No mktexlsr/texhash/initexmf found. You may not need to refresh for TEXMFHOME."
  fi
}

refresh_user_db

if [[ "$UNINSTALL" -eq 1 ]]; then
  log "Uninstall complete."
else
  log "Install complete. Try using: \\usepackage{notestyle-all}"
  log "Installed at: $TARGET"
fi