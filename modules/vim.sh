#!/usr/bin/env bash

link_vimrc() {
  local src="${DOTFILES:?}/home/vimrc"
  local dst="$HOME/.vimrc"
  [[ -f "$src" ]] || die "vimrc not found: $src"
  link_one "$src" "$dst"
}

link_vim_dir_preserve_plugged() {
  local src_root="${DOTFILES:?}/home/vim"
  local dst_root="$HOME/.vim"

  [[ -d "$src_root" ]] || die "vim dir not found: $src_root"
  ensure_dir "$dst_root"

  local sub base
  for sub in "$src_root"/*; do
    [[ -e "$sub" ]] || continue
    base="$(basename "$sub")"
    [[ "$base" == "plugged" ]] && continue
    link_one "$sub" "$dst_root/$base"
  done
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  vim disabled"; return 0; }

  link_vimrc
  link_vim_dir_preserve_plugged
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi

