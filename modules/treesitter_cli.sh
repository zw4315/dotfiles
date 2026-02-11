#!/usr/bin/env bash

ensure_treesitter_build_deps() {
  log "📦 tree-sitter-cli: ensuring build deps (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_install_pkgs clang libclang-dev llvm-dev build-essential pkg-config
}

ensure_cargo() {
  command -v cargo >/dev/null 2>&1 && return 0
  [[ -x "$HOME/.cargo/bin/cargo" ]] && return 0
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "ℹ️  tree-sitter-cli: cargo not found (dry-run). Enable rustup=1 to install Rust, then re-run."
    return 1
  fi
  die "cargo not found. Enable rustup=1 (or install Rust) and open a new shell so cargo is on PATH."
}

ensure_tree_sitter_cli() {
  if command -v tree-sitter >/dev/null 2>&1; then
    log "✅ tree-sitter-cli: already installed"
    return 0
  fi

  if ! ensure_cargo; then
    return 0
  fi

  log "📦 tree-sitter-cli: installing via cargo"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: cargo install tree-sitter-cli --locked"
    return 0
  fi

  cargo install tree-sitter-cli --locked

  if [[ -x "$HOME/.cargo/bin/tree-sitter" ]]; then
    log "✅ tree-sitter-cli: installed ($HOME/.cargo/bin/tree-sitter)"
    return 0
  fi
  command -v tree-sitter >/dev/null 2>&1 || die "tree-sitter-cli install failed (tree-sitter not found)"
  log "✅ tree-sitter-cli: installed"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  treesitter_cli disabled"; return 0; }

  ensure_treesitter_build_deps
  ensure_tree_sitter_cli

  log 'ℹ️  If your current shell can’t find `tree-sitter`, run: source ~/.profile  &&  hash -r'
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
