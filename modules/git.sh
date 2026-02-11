#!/usr/bin/env bash

ensure_git() {
  command -v git >/dev/null 2>&1 && { log "✅ git: already installed"; return 0; }

  log "📦 git: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd git git
  log "✅ git: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  git disabled"; return 0; }
  ensure_git
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
