#!/usr/bin/env bash

link_scripts() {
  local src_dir="${DOTFILES:?}/scripts"
  local dst_dir="$HOME/.local/bin"

  [[ -d "$src_dir" ]] || { log "ℹ️  scripts: not found (skip): $src_dir"; return 0; }

  ensure_dir "$dst_dir"

  local path name
  for path in "$src_dir"/*; do
    [[ -f "$path" ]] || continue
    name="$(basename "$path")"

    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🔗 (dry-run) Linked $dst_dir/$name → $path"
      continue
    fi

    chmod +x "$path" 2>/dev/null || true
    link_one "$path" "$dst_dir/$name"
  done

  # Backward-compatible aliases for old `.sh` names.
  if [[ -f "$src_dir/run_gost" ]]; then
    link_one "$src_dir/run_gost" "$dst_dir/run_gost.sh"
  fi
  if [[ -f "$src_dir/sync_to_gdrive" ]]; then
    link_one "$src_dir/sync_to_gdrive" "$dst_dir/sync_to_gdrive.sh"
  fi

  if ! echo "${PATH:-}" | grep -q "$dst_dir"; then
    log 'ℹ️  Tip: ensure PATH includes ~/.local/bin (e.g. via ~/.profile / dotfiles home/profile)'
  fi
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  scripts disabled"; return 0; }
  link_scripts
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
