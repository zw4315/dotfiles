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
  pkg_install_auto "$APP_NAME"
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
