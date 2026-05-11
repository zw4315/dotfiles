#!/usr/bin/env bash
# =============================================================================
# App: SSH
# =============================================================================
# SSH 客户端配置。仅管理 ~/.ssh/config，不涉及私钥。
# =============================================================================

APP_NAME="ssh"
APP_DESC="SSH client configuration"
APP_DEPS=()

app_install() {
  :
}

app_configure() {
  # 确保 ~/.ssh 目录存在且权限正确
  ensure_dir "$HOME/.ssh"
  if [[ "${DRY_RUN:-0}" -ne 1 ]]; then
    chmod 700 "$HOME/.ssh"
  fi

  # 链接 config 文件
  link_file "$APP_DIR/config/config" "$HOME/.ssh/config"

  # 确保 config 文件权限严格（OpenSSH 要求 600）
  if [[ "${DRY_RUN:-0}" -ne 1 ]]; then
    chmod 600 "$HOME/.ssh/config"
  fi
}

app_post_install() {
  log_info "  SSH configured."
}
