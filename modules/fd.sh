#!/usr/bin/env bash

ensure_fd() {
  if command -v fd >/dev/null 2>&1; then
    log "✅ fd: already installed"
    return 0
  fi

  if command -v fdfind >/dev/null 2>&1; then
    # Ubuntu's fd package provides `fdfind`; create a convenient `fd` shim.
    local src
    src="$(command -v fdfind)"
    ensure_dir "$HOME/.local/bin"
    link_one "$src" "$HOME/.local/bin/fd"
    log "✅ fd: provided via fdfind -> ~/.local/bin/fd"
    return 0
  fi

  log "📦 fd: installing (apt fd-find)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_install_pkgs fd-find

  command -v fd >/dev/null 2>&1 && { log "✅ fd: installed"; return 0; }
  command -v fdfind >/dev/null 2>&1 || die "fd-find install failed (missing fdfind)"

  local src
  src="$(command -v fdfind)"
  ensure_dir "$HOME/.local/bin"
  link_one "$src" "$HOME/.local/bin/fd"
  command -v fd >/dev/null 2>&1 || die "fd shim install failed"
  log "✅ fd: installed (fdfind + shim)"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  fd disabled"; return 0; }
  ensure_fd
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
