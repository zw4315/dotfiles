#!/usr/bin/env bash
# =============================================================================
# App: fd (fd-find)
# =============================================================================
# 快速的替代 find 的命令行工具。
# =============================================================================

APP_NAME="fd"
APP_DESC="A simple, fast and user-friendly alternative to find"
APP_DEPS=()

APP_BREW_FORMULA="fd"
APP_APT_PACKAGE="fd-find"

app_install() {
  pkg_install_auto "$APP_NAME"

  # Ubuntu/Debian 的 fd 包提供的是 fdfind 命令，创建 fd shim
  if [[ "${DETECTED_OS:-}" == "linux" ]]; then
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
      local src
      src="$(command -v fdfind)"
      ensure_dir "$HOME/.local/bin"
      if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        log "  [dry-run] Would link: $src -> $HOME/.local/bin/fd"
      else
        ln -sfn "$src" "$HOME/.local/bin/fd"
        log_success "  Linked fd shim: $HOME/.local/bin/fd"
      fi
    fi
  fi
}

app_configure() {
  :
}

app_post_install() {
  if has_cmd fd; then
    log_info "  fd configured. Try: fd --version"
  fi
}
