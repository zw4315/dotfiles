#!/usr/bin/env bash

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  nvim disabled"; return 0; }

  # Ensure a recent-enough nvim is installed (AppImage) before linking config.
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/appimage.sh"
  local -a MIN_VERSIONS=( nvim=0.11.2 )
  local -a VERSION_PATTERNS=( nvim='^NVIM v\([0-9]\+\.[0-9]\+\.[0-9]\+\).*' )
  appimage_ensure "nvim=neovim/neovim:nvim-linux-x86_64.appimage:nvim-linux-arm64.appimage"

  local src="$DOTFILES/config/nvim"
  local dst="$HOME/.config/nvim"

  [[ -d "$src" ]] || die "nvim config not found: $src"

  ensure_dir "$HOME/.config"
  link_one "$src" "$dst"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
