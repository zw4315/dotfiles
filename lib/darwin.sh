#!/usr/bin/env bash
# =============================================================================
# macOS (Darwin) 平台抽象层
# =============================================================================
# 提供 macOS 特定的包管理、系统设置等能力。
# =============================================================================

# 检测 Homebrew 前缀（支持 Apple Silicon 和 Intel）
_detect_brew_prefix() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    echo "/opt/homebrew"
  elif [[ -x /usr/local/bin/brew ]]; then
    echo "/usr/local"
  elif has_cmd brew; then
    brew --prefix
  else
    echo ""
  fi
}

BREW_PREFIX="$(_detect_brew_prefix)"

# 确保 Homebrew 已安装
ensure_brew() {
  if has_cmd brew; then
    return 0
  fi

  log "Homebrew not found, installing..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would install Homebrew"
    return 0
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # 重新检测
  BREW_PREFIX="$(_detect_brew_prefix)"
  eval "$("$BREW_PREFIX/bin/brew" shellenv)"
}

# =============================================================================
# 包管理器实现
# =============================================================================

pkg_is_installed() {
  local pkg="$1"
  brew list "$pkg" &>/dev/null
}

pkg_install() {
  local pkg="$1"
  ensure_brew

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would brew install $pkg"
    return 0
  fi

  brew install "$pkg"
}

pkg_install_cask() {
  local pkg="$1"
  ensure_brew

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would brew install --cask $pkg"
    return 0
  fi

  brew install --cask "$pkg"
}

# =============================================================================
# macOS 系统设置工具
# =============================================================================

# 设置 macOS 默认值（带类型）
macos_default() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would set default: $domain $key = $value ($type)"
    return 0
  fi

  defaults write "$domain" "$key" -"$type" "$value"
}

# 重启 macOS 服务以应用更改
kill_affected_apps() {
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    return 0
  fi

  local apps=(
    "Finder"
    "Dock"
    "SystemUIServer"
    "ControlCenter"
  )

  for app in "${apps[@]}"; do
    killall "$app" &>/dev/null || true
  done
}
