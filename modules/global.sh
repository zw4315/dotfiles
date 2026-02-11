#!/usr/bin/env bash

ensure_global_installed() {
  command -v gtags >/dev/null 2>&1 && { log "✅ global(gtags): already installed"; return 0; }

  log "📦 global(gtags): installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_install_pkgs global python3-pygments

  command -v gtags >/dev/null 2>&1 || die "global(gtags) install failed (missing gtags)"
  log "✅ global(gtags): installed"
}

link_global_config() {
  local src="${DOTFILES:?}/home/global"
  local dst="$HOME/.global"
  [[ -d "$src" ]] || die "global config dir not found: $src"
  link_one "$src" "$dst"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  global disabled"; return 0; }

  ensure_global_installed
  link_global_config
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi

