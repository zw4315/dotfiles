#!/usr/bin/env bash

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  tmux disabled"; return 0; }

  local src="$DOTFILES/files/tmux.conf"
  local dst="$HOME/.tmux.conf"

  [[ -f "$src" ]] || die "tmux config not found: $src"
  link_one "$src" "$dst"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi

