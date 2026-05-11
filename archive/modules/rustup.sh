#!/usr/bin/env bash

ensure_rustup() {
  if command -v rustup >/dev/null 2>&1; then
    log "✅ rustup: already installed"
    return 0
  fi

  # rustup usually installs into ~/.cargo/bin
  if [[ -x "$HOME/.cargo/bin/rustup" ]]; then
    log "✅ rustup: already installed ($HOME/.cargo/bin/rustup)"
    return 0
  fi

  log "📦 rustup: installing via sh.rustup.rs"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- https://sh.rustup.rs | sh -s -- -y
  else
    die "Need curl or wget to install rustup"
  fi

  if ! command -v rustup >/dev/null 2>&1 && [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    die "rustup install failed"
  fi

  log "✅ rustup: installed"
  log "ℹ️  Tip: open a new shell or run: source \"$HOME/.cargo/env\""
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  rustup disabled"; return 0; }
  ensure_rustup
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi

