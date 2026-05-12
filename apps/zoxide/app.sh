#!/usr/bin/env bash
# =============================================================================
# App: Zoxide
# =============================================================================
# 跨平台的 smarter cd 命令。
# =============================================================================

APP_NAME="zoxide"
APP_DESC="A smarter cd command"
APP_DEPS=()

APP_BREW_FORMULA="zoxide"
APP_APT_PACKAGE="zoxide"

app_install() {
  if has_cmd zoxide; then
    log_info "  Already installed: zoxide"
    return 0
  fi

  # Linux apt 仓库通常没有 zoxide，改用官方安装脚本
  if [[ "${DETECTED_OS:-}" == "linux" && "${PKG_MANAGER:-}" == "apt" ]]; then
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "  [dry-run] Would install zoxide via official install script"
      return 0
    fi
    log "  Installing zoxide via official install script"
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  else
    pkg_install_auto "$APP_NAME"
  fi
}

app_configure() {
  # 在 shell 配置中初始化 zoxide
  # 同时支持 zsh 和 bash，各自独立注入
  if [[ -f "$HOME/.zshrc" ]]; then
    append_if_missing 'eval "$(zoxide init zsh)"' "$HOME/.zshrc"
  fi

  if [[ -f "$HOME/.bashrc" ]]; then
    append_if_missing 'eval "$(zoxide init bash)"' "$HOME/.bashrc"
  fi
}

app_post_install() {
  log_info "  Zoxide configured. Use 'z <pattern>' for smarter cd."
}
