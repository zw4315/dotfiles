#!/usr/bin/env bash

ensure_nvm() {
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  local nvm_sh="$nvm_dir/nvm.sh"

  if [[ -s "$nvm_sh" ]]; then
    log "✅ nvm: already installed ($nvm_sh)"
    return 0
  fi

  log "📦 nvm: installing -> $nvm_dir"

  # Pin to the same version referenced by bashrc.
  local ver="${NVM_VERSION:-v0.40.3}"
  local url="https://raw.githubusercontent.com/nvm-sh/nvm/${ver}/install.sh"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run nvm installer: $url"
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    NVM_DIR="$nvm_dir" curl -fsSL "$url" | bash
  elif command -v wget >/dev/null 2>&1; then
    NVM_DIR="$nvm_dir" wget -qO- "$url" | bash
  else
    die "Need curl or wget to install nvm"
  fi

  [[ -s "$nvm_sh" ]] || die "nvm install failed (missing): $nvm_sh"
  log "✅ nvm: installed ($nvm_sh)"
}

link_profile_d_config() {
  local src="${DOTFILES:?}/home/profile.d/nvm.sh"
  local dst_dir="$HOME/.profile.d"
  local dst="$dst_dir/nvm.sh"

  [[ -f "$src" ]] || die "nvm profile snippet not found: $src"
  ensure_dir "$dst_dir"
  link_one "$src" "$dst"
}

install_node_lts() {
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  local nvm_sh="$nvm_dir/nvm.sh"

  # Source nvm to use it
  # shellcheck source=/dev/null
  export NVM_DIR="$nvm_dir"
  # shellcheck source=/dev/null
  [ -s "$nvm_sh" ] && . "$nvm_sh"

  # Check if Node LTS is already installed
  if nvm ls --lts >/dev/null 2>&1 | grep -q "v22"; then
    log "✅ Node LTS: already installed"
  else
    log "📦 Node LTS: installing..."
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🧪 (dry-run) Would install Node LTS"
    else
      nvm install --lts
    fi
  fi

  # Set LTS as default
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would set Node LTS as default"
  else
    nvm alias default lts/*
    log "✅ Node LTS: set as default"
  fi
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  nvm disabled"; return 0; }
  ensure_nvm
  link_profile_d_config
  install_node_lts
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi

