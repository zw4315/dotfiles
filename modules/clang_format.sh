#!/usr/bin/env bash

ensure_clang_format() {
  command -v clang-format >/dev/null 2>&1 && { log "✅ clang-format: already installed"; return 0; }

  log "📦 clang-format: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd clang-format clang-format
  log "✅ clang-format: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  clang-format disabled"; return 0; }
  ensure_clang_format
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
