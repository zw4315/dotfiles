#!/usr/bin/env bash
# =============================================================================
# Dotfiles 共享工具库
# =============================================================================
# 这个文件被所有脚本 source，提供基础工具函数。
# 注意：不包含任何平台特定的逻辑（包管理器等）。
# =============================================================================

# 颜色定义
if [[ -t 1 ]]; then
  readonly C_RESET='\033[0m'
  readonly C_BOLD='\033[1m'
  readonly C_RED='\033[0;31m'
  readonly C_GREEN='\033[0;32m'
  readonly C_YELLOW='\033[0;33m'
  readonly C_BLUE='\033[0;34m'
  readonly C_DIM='\033[0;90m'
else
  readonly C_RESET=''
  readonly C_BOLD=''
  readonly C_RED=''
  readonly C_GREEN=''
  readonly C_YELLOW=''
  readonly C_BLUE=''
  readonly C_DIM=''
fi

# =============================================================================
# 日志与输出
# =============================================================================

log() {
  printf "${C_BLUE}→${C_RESET} %s\n" "$1"
}

log_success() {
  printf "${C_GREEN}✓${C_RESET} %s\n" "$1"
}

log_warn() {
  printf "${C_YELLOW}⚠${C_RESET} %s\n" "$1" >&2
}

log_info() {
  printf "${C_DIM}ℹ${C_RESET} %s\n" "$1"
}

die() {
  printf "${C_RED}✗${C_RESET} %s\n" "$1" >&2
  exit 1
}

# =============================================================================
# 文件与目录操作
# =============================================================================

# 确保目录存在
ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "  [dry-run] Would create directory: $dir"
    else
      mkdir -p "$dir"
    fi
  fi
}

# 安全地创建符号链接（自动备份已存在的文件）
link_file() {
  local src="$1"
  local dst="$2"

  if [[ ! -e "$src" ]]; then
    log_warn "Source does not exist: $src"
    return 1
  fi

  # 如果已经是正确的符号链接，跳过
  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      log_info "  Already linked: $dst"
      return 0
    fi
  fi

  # 备份已存在的文件
  if [[ -e "$dst" ]]; then
    local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "  [dry-run] Would backup $dst → $backup"
    else
      mv "$dst" "$backup"
      log_info "  Backed up: $dst → $backup"
    fi
  fi

  # 确保目标目录存在
  ensure_dir "$(dirname "$dst")"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would link: $src → $dst"
  else
    ln -sfn "$src" "$dst"
    log_success "  Linked: $dst"
  fi
}

# 链接配置目录（XDG 风格）
link_config_dir() {
  local src="$1"
  local name="$2"
  local dst="${XDG_CONFIG_HOME:-$HOME/.config}/$name"
  link_file "$src" "$dst"
}

# 链接单个配置文件到 $HOME
link_home_file() {
  local src="$1"
  local name="$2"
  local dst="$HOME/$name"
  link_file "$src" "$dst"
}

# =============================================================================
# 平台无关的包管理器抽象
# =============================================================================
# 以下函数需要被 lib/darwin.sh, lib/linux.sh 等覆盖实现
# =============================================================================

# 检查命令是否存在
has_cmd() {
  command -v "$1" &>/dev/null
}

# 安装包（需要在 OS 层实现）
pkg_install() {
  die "pkg_install() not implemented for this OS"
}

# 检查包是否已安装（需要在 OS 层实现）
pkg_is_installed() {
  die "pkg_is_installed() not implemented for this OS"
}

# 根据 App 元数据自动选择包名安装
pkg_install_auto() {
  local app_name="$1"

  # 查找 App 的包名声明
  local brew_var="APP_BREW_FORMULA"
  local apt_var="APP_APT_PACKAGE"
  local winget_var="APP_WINGET_ID"

  # 注意：这些变量需要在 source app.sh 后设置
  local pkg_name=""

  case "${DETECTED_OS:-}" in
    darwin)
      pkg_name="${!brew_var:-}"
      ;;
    linux)
      pkg_name="${!apt_var:-}"
      ;;
    windows)
      pkg_name="${!winget_var:-}"
      ;;
  esac

  if [[ -z "$pkg_name" ]]; then
    log_warn "  No package name defined for $app_name on $DETECTED_OS"
    return 1
  fi

  if pkg_is_installed "$pkg_name"; then
    log_info "  Already installed: $pkg_name"
    return 0
  fi

  log "  Installing: $pkg_name"
  pkg_install "$pkg_name"
}

# =============================================================================
# Git 相关工具
# =============================================================================

git_clone_or_pull() {
  local repo="$1"
  local dest="$2"
  local branch="${3:-main}"

  if [[ -d "$dest/.git" ]]; then
    log "  Updating: $dest"
    if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
      (cd "$dest" && git pull --ff-only)
    fi
  else
    log "  Cloning: $repo → $dest"
    if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
      git clone --depth 1 --branch "$branch" "$repo" "$dest"
    fi
  fi
}

# =============================================================================
# Shell 配置注入
# =============================================================================

# 向指定 shell 配置文件添加一行（避免重复）
append_if_missing() {
  local line="$1"
  local file="$2"

  ensure_dir "$(dirname "$file")"

  if [[ -f "$file" ]] && grep -Fxq "$line" "$file"; then
    return 0
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would append to $file: $line"
  else
    echo "$line" >> "$file"
    log_info "  Appended to $file"
  fi
}
