#!/usr/bin/env bash

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  path disabled"; return 0; }

  local marker="# dotfiles:path (managed)"
  local line='export PATH="$HOME/.local/bin:$PATH"'

  local targets=("$HOME/.profile" "$HOME/.bashrc")
  local file
  for file in "${targets[@]}"; do
    if [[ -f "$file" ]] && grep -Fq "$marker" "$file" 2>/dev/null; then
      log "✅ path: already configured in $file"
      continue
    fi

    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🧪 (dry-run) Would append PATH snippet to: $file"
      continue
    fi

    {
      echo
      echo "$marker"
      echo "$line"
    } >>"$file"
    log "✍️  path: appended snippet to $file"
  done

  log "ℹ️  Restart your shell (or run: hash -r) to pick up PATH changes."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
