#!/usr/bin/env bash
# =============================================================================
# App: Pyright (Python LSP)
# =============================================================================
# Microsoft 的 Python 语言服务器，基于 Node.js，用于 Vim/Neovim 的 LSP
# 跳转、补全、诊断等功能。
# =============================================================================

APP_NAME="pyright"
APP_DESC="Python language server for LSP (via npm)"
APP_DEPS=("node")

# 不通过系统包管理器，而是通过 npm 全局安装
app_install() {
  if has_cmd pyright-langserver; then
    log_info "  Already installed: pyright-langserver"
    return 0
  fi

  if ! has_cmd npm; then
    die "npm not found. Please install the 'node' app first."
  fi

  log "  Installing pyright via npm..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would run: npm install -g pyright"
    return 0
  fi

  npm install -g pyright || die "pyright installation failed"
  log_success "  pyright installed"
}

app_configure() {
  :
}

app_post_install() {
  if has_cmd pyright-langserver; then
    log_info "  pyright configured. Try: pyright-langserver --version"
  fi
}
