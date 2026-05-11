#!/usr/bin/env bash

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  rust disabled"; return 0; }

  local src="${DOTFILES:?}/home/profile.d/rust.sh"
  local dst_dir="$HOME/.profile.d"
  local dst="$dst_dir/50-rust.sh"

  [[ -f "$src" ]] || die "rust profile snippet not found: $src"
  ensure_dir "$dst_dir"
  link_one "$src" "$dst"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi

