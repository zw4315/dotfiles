#!/usr/bin/env bash
# =============================================================================
# Linux 平台抽象层
# =============================================================================
# 提供 Linux 特定的包管理能力，支持多种发行版。
# =============================================================================

# 检测发行版包管理器
_detect_package_manager() {
  if has_cmd apt-get; then
    echo "apt"
  elif has_cmd pacman; then
    echo "pacman"
  elif has_cmd dnf; then
    echo "dnf"
  elif has_cmd apk; then
    echo "apk"
  else
    echo "unknown"
  fi
}

PKG_MANAGER="$(_detect_package_manager)"

# =============================================================================
# 包管理器实现
# =============================================================================

pkg_is_installed() {
  local pkg="$1"

  case "$PKG_MANAGER" in
    apt)
      dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"
      ;;
    pacman)
      pacman -Q "$pkg" &>/dev/null
      ;;
    dnf)
      rpm -q "$pkg" &>/dev/null
      ;;
    apk)
      apk info -e "$pkg" &>/dev/null
      ;;
    *)
      return 1
      ;;
  esac
}

pkg_install() {
  local pkg="$1"

  if pkg_is_installed "$pkg"; then
    log_info "  Already installed: $pkg"
    return 0
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would install $pkg via $PKG_MANAGER"
    return 0
  fi

  case "$PKG_MANAGER" in
    apt)
      sudo apt-get update -qq
      sudo apt-get install -y -qq "$pkg"
      ;;
    pacman)
      sudo pacman -S --noconfirm "$pkg"
      ;;
    dnf)
      sudo dnf install -y "$pkg"
      ;;
    apk)
      sudo apk add "$pkg"
      ;;
    *)
      die "Unknown package manager"
      ;;
  esac
}
