#!/usr/bin/env bash

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  bash disabled"; return 0; }

  local bashrc_src="$DOTFILES/home/bashrc"
  local profile_src="$DOTFILES/home/profile"
  local aliases_src="$DOTFILES/home/bash_aliases"
  local proxy_src="$DOTFILES/home/proxyrc"

  [[ -f "$bashrc_src" ]] || die "bashrc not found: $bashrc_src"
  [[ -f "$aliases_src" ]] || die "bash_aliases not found: $aliases_src"
  [[ -f "$proxy_src" ]] || die "proxyrc not found: $proxy_src"
  [[ -f "$profile_src" ]] || die "profile not found: $profile_src"

  link_one "$bashrc_src" "$HOME/.bashrc"
  link_one "$profile_src" "$HOME/.profile"
  link_one "$aliases_src" "$HOME/.bash_aliases"
  link_one "$proxy_src" "$HOME/.proxyrc"

  log "ℹ️  bash: restart your shell (or re-source ~/.bashrc) to apply."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
