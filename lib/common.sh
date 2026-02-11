#!/usr/bin/env bash
set -euo pipefail

log() { printf '%s\n' "$*"; }
die() { log "ERROR: $*" >&2; exit 1; }

is_enabled() {
  local v="${1:-1}"
  case "$v" in
    0|off|OFF|false|FALSE|no|NO) return 1 ;;
    *) return 0 ;;
  esac
}

ensure_dir() {
  local dir="$1"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "📁 (dry-run) Ensure dir: $dir"
    return 0
  fi
  mkdir -p "$dir"
}

link_one() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log "✅ $dst already linked"
    return 0
  fi

  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="${dst}.backup.$(date +%s)"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "💾 (dry-run) Backup $dst -> $backup"
    else
      mv "$dst" "$backup"
      log "💾 Backup $dst"
    fi
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🔗 (dry-run) Linked $dst → $src"
  else
    ln -sfn "$src" "$dst"
    log "🔗 Linked $dst → $src"
  fi
}

