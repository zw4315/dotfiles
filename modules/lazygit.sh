#!/usr/bin/env bash

ensure_lazygit() {
  command -v lazygit >/dev/null 2>&1 && { log "✅ lazygit: already installed"; return 0; }

  log "📦 lazygit: installing from GitHub releases"

  local version="${LAZYGIT_VERSION:-0.59.0}"
  local arch="${LAZYGIT_ARCH:-linux_x86_64}"
  local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_${arch}.tar.gz"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would download: $url"
    log "🧪 (dry-run) Would extract lazygit to ~/.local/bin/"
    return 0
  fi

  ensure_dir "$HOME/.local/bin"

  log "⬇️  lazygit: downloading from $url"
  if command -v curl >/dev/null 2>&1; then
    curl -sL "$url" | tar -C "$tmp_dir" -xzf -
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- "$url" | tar -C "$tmp_dir" -xzf -
  else
    rm -rf "$tmp_dir"
    die "Need curl or wget to install lazygit"
  fi

  if [[ ! -f "$tmp_dir/lazygit" ]]; then
    rm -rf "$tmp_dir"
    die "lazygit download/extract failed (binary not found)"
  fi

  chmod +x "$tmp_dir/lazygit"
  mv "$tmp_dir/lazygit" "$HOME/.local/bin/lazygit"
  rm -rf "$tmp_dir"

  command -v lazygit >/dev/null 2>&1 || die "lazygit install failed"
  log "✅ lazygit: installed to ~/.local/bin/lazygit"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  lazygit disabled"; return 0; }
  ensure_lazygit
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
