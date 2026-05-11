#!/usr/bin/env bash
# =============================================================================
# App: Mihomo (Clash.Meta)
# =============================================================================
# 代理工具，跨平台支持 Linux/macOS/Windows。
# =============================================================================

APP_NAME="mihomo"
APP_DESC="Mihomo (Clash.Meta) proxy tool"
APP_DEPS=(bash)

# Mihomo 不在标准包管理器中，通过 GitHub Release 下载
# APP_BREW_FORMULA=""
# APP_APT_PACKAGE=""

MIHOMO_VERSION="${MIHOMO_VERSION:-1.19.20}"

_mihomo_platform() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *) die "Unsupported architecture: $arch" ;;
  esac

  local os
  os="$(uname -s)"
  case "$os" in
    Linux) os="linux" ;;
    Darwin) os="darwin" ;;
    MINGW*|MSYS*) os="windows" ;;
    *) die "Unsupported OS: $os" ;;
  esac

  echo "${os}-${arch}"
}

app_install() {
  if has_cmd mihomo; then
    log_info "  Already installed: mihomo"
    return 0
  fi

  local platform
  platform="$(_mihomo_platform)"
  local bin_dir="$HOME/.local/bin"
  local bin_path="${bin_dir}/mihomo"

  log "  Downloading mihomo v${MIHOMO_VERSION} (${platform})..."

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would download mihomo ${platform} to ${bin_path}"
    return 0
  fi

  local url="https://github.com/MetaCubeX/mihomo/releases/download/v${MIHOMO_VERSION}/mihomo-${platform}-v${MIHOMO_VERSION}.gz"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local gzfile="${tmp_dir}/mihomo.gz"

  if ! curl -fSL "$url" -o "$gzfile" 2>/dev/null; then
    rm -rf "$tmp_dir"
    log_warn "  Failed to download mihomo. Please install manually: https://github.com/MetaCubeX/mihomo"
    return 0
  fi

  if ! gzip -d "$gzfile"; then
    rm -rf "$tmp_dir"
    log_warn "  Failed to decompress mihomo"
    return 0
  fi

  ensure_dir "$bin_dir"
  mv "${tmp_dir}/mihomo" "$bin_path"
  rm -rf "$tmp_dir"
  chmod +x "$bin_path"

  log_success "  mihomo installed to ${bin_path}"
}

app_configure() {
  local src="$DOTFILES/config/mihomo"
  link_config_dir "$src" "mihomo"

  # 链接 mihomo 专用 alias 和函数
  local aliases_src="$DOTFILES/home/bash_aliases_mihd"
  if [[ -f "$aliases_src" ]]; then
    link_home_file "$aliases_src" ".bash_aliases_mihd"
  fi

  # 首次配置：复制模板并提示用户编辑
  local config_dir="$HOME/.config/mihomo"
  local dst="${config_dir}/config.yaml"
  local template="$DOTFILES/config/mihomo/config.yaml"

  if [[ -f "$template" && ! -f "$dst" ]]; then
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "  [dry-run] Would copy mihomo config template"
    else
      cp "$template" "$dst"
      log_info "  Copied mihomo config template: ${dst}"
      log_warn "  Please edit ${dst} and add your subscription URL"
    fi
  fi
}

app_post_install() {
  log_info "  Mihomo configured. Config: ~/.config/mihomo"
}
