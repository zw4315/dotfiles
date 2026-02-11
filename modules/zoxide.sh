#!/usr/bin/env bash

ensure_zoxide() {
  command -v zoxide >/dev/null 2>&1 && { log "✅ zoxide: already installed"; return 0; }

  log "📦 zoxide: installing (apt; fallback: install.sh)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"

  if dotfiles_apt_try_ensure_cmd zoxide zoxide; then
    log "✅ zoxide: installed (apt)"
    return 0
  fi

  log "⚠️  zoxide: apt install failed; trying upstream install.sh"
  local url="https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh"
  if command -v curl >/dev/null 2>&1; then
    curl -sS "$url" | bash
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$url" | bash
  else
    die "Need curl or wget for zoxide install.sh fallback"
  fi

  command -v zoxide >/dev/null 2>&1 || die "zoxide install failed"
  log "✅ zoxide: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  zoxide disabled"; return 0; }
  ensure_zoxide
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
