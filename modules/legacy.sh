#!/usr/bin/env bash

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  legacy disabled"; return 0; }

  log "▶ legacy: running $DOTFILES/setup"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "ℹ️  (dry-run) legacy installer is not executed"
    return 0
  fi

  bash "$DOTFILES/setup"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
