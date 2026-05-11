#!/usr/bin/env bash
# =============================================================================
# App: Tmux
# =============================================================================
# 终端复用器配置。
# =============================================================================

APP_NAME="tmux"
APP_DESC="Terminal multiplexer"
APP_DEPS=()

APP_BREW_FORMULA="tmux"
APP_APT_PACKAGE="tmux"

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  local config_dir="$APP_DIR/config"
  link_home_file "$config_dir/tmux.conf" ".tmux.conf"
}

app_post_install() {
  log_info "  Tmux configured. Start with: tmux"
}
