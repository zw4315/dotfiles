#!/usr/bin/env bash
# =============================================================================
# App: Git
# =============================================================================
# 跨平台共享的 Git 配置。
# =============================================================================

APP_NAME="git"
APP_DESC="Distributed version control system"
APP_DEPS=()

# 包名声明（供 pkg_install_auto 使用）
APP_BREW_FORMULA="git"
APP_APT_PACKAGE="git"

# Delta 包名（按平台）
DELTA_BREW_FORMULA="git-delta"
DELTA_APT_PACKAGE="git-delta"

# 默认安装：使用平台包管理器
app_install() {
  # 尝试自动安装，如果失败则跳过（因为 git 通常已预装）
  pkg_install_auto "$APP_NAME" || true

  # 尝试安装 delta（增强 diff/pager），失败不阻塞
  local delta_pkg=""
  case "${DETECTED_OS:-}" in
    darwin) delta_pkg="$DELTA_BREW_FORMULA" ;;
    linux)  delta_pkg="$DELTA_APT_PACKAGE" ;;
  esac

  if [[ -n "$delta_pkg" ]]; then
    log "  Installing optional: $delta_pkg"
    pkg_install "$delta_pkg" || log_warn "  $delta_pkg not installed, will use default pager"
  fi
}

# 配置：链接共享的 git 配置
app_configure() {
  local config_dir="$APP_DIR/config"

  link_home_file "$config_dir/gitconfig" ".gitconfig"
  link_home_file "$config_dir/gitignore_global" ".gitignore_global"
}

# 安装后：设置一些动态配置
app_post_install() {
  local gitconfig_local="$HOME/.gitconfig_local"
  ensure_dir "$(dirname "$gitconfig_local")"

  # 如果 delta 已安装，配置它为 pager；否则 fallback 到默认 pager
  if has_cmd delta; then
    git config --file "$gitconfig_local" core.pager "delta"
    git config --file "$gitconfig_local" delta.side-by-side "true"
    git config --file "$gitconfig_local" delta.line-numbers "true"
  else
    git config --file "$gitconfig_local" --unset core.pager 2>/dev/null || true
    log_info "  Using default git pager (delta not available)"
  fi

  # macOS 特定：使用 Keychain 作为凭证助手
  if [[ "$DETECTED_OS" == "darwin" ]]; then
    git config --file "$gitconfig_local" credential.helper osxkeychain
  fi
}
