#!/usr/bin/env bash
# 30-dev-env.sh - 开发环境工具模块
# 安装开发工具链：git, lazygit, rg, fd, ctags, global, clang_format

# Git
ensure_git() {
  command -v git >/dev/null 2>&1 && { log "✅ git: already installed"; return 0; }

  log "📦 git: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd git git
  log "✅ git: installed"
}

# Lazygit
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

# Ripgrep
ensure_rg() {
  command -v rg >/dev/null 2>&1 && { log "✅ rg: already installed"; return 0; }

  log "📦 rg: installing (apt)"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/lib/apt_helpers.sh"
  dotfiles_apt_ensure_cmd rg ripgrep
  log "✅ rg: installed"
}

# fd
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

# Ctags (Universal Ctags)
ensure_ctags() {
  if command -v ctags >/dev/null 2>&1; then
    local version
    version="$(ctags --version 2>&1 | head -1)"
    if [[ "$version" == *"Universal Ctags"* ]]; then
      log "✅ ctags: already installed (Universal Ctags)"
      return 0
    fi
    log "⚠️ ctags: found but not Universal Ctags, will install..."
  fi

  log "📦 ctags: installing Universal Ctags from source"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/ctags.sh"
  module_main 1
}

# Global (gtags)
ensure_global() {
  command -v gtags >/dev/null 2>&1 && { log "✅ global: already installed"; return 0; }

  log "📦 global: installing"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/global.sh"
  module_main 1
}

# Clang Format
ensure_clang_format() {
  command -v clang-format >/dev/null 2>&1 && { log "✅ clang-format: already installed"; return 0; }

  log "📦 clang-format: installing"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/clang_format.sh"
  module_main 1
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  dev-env disabled"; return 0; }

  log "🔧 Installing development environment tools..."
  ensure_git
  ensure_lazygit
  ensure_rg
  ensure_fd
  ensure_ctags
  ensure_global
  ensure_clang_format
  log "✅ Development environment tools installed"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
