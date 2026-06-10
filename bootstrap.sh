#!/usr/bin/env bash
set -euo pipefail

DOTFILES_URL="${DOTFILES_URL:-https://github.com/zw4315/dotfiles}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }

main() {
  if [[ -d "$DOTFILES_DIR/.git" ]]; then
    log "Dotfiles already exists at $DOTFILES_DIR, pulling latest..."
    cd "$DOTFILES_DIR"
    git pull --ff-only 2>/dev/null || log "Git pull failed, using existing files"
  elif [[ -d "$DOTFILES_DIR" ]]; then
    log "Directory $DOTFILES_DIR exists but not a git repo, removing..."
    rm -rf "$DOTFILES_DIR"
    git clone --depth=1 "$DOTFILES_URL" "$DOTFILES_DIR"
  else
    git clone --depth=1 "$DOTFILES_URL" "$DOTFILES_DIR"
  fi

  log "Running init.sh..."
  cd "$DOTFILES_DIR"
  exec ./init.sh "$@"
}

main "$@"
