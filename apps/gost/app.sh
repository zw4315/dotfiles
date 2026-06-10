#!/usr/bin/env bash

APP_NAME="gost"
APP_DESC="GOST proxy tunnel server"
APP_DEPS=()

GOST_VERSION="${GOST_VERSION:-2.11.5}"

app_install() {
  if [[ -x "$HOME/app/gost" ]]; then
    log_info "  Already installed: gost"
    return 0
  fi

  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64)        arch="amd64" ;;
    aarch64|arm64) arch="armv8" ;;
    *) die "Unsupported architecture: $arch" ;;
  esac

  local os
  os="$(uname -s)"
  case "$os" in
    Linux)  os="linux" ;;
    *) die "Unsupported OS: $os" ;;
  esac

  local platform="${os}-${arch}"
  local app_dir="$HOME/app"
  local bin_path="${app_dir}/gost"

  log "  Downloading gost v${GOST_VERSION} (${platform})..."

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would download gost ${platform} to ${bin_path}"
    return 0
  fi

  ensure_dir "$app_dir"

  local url="https://github.com/ginuerzh/gost/releases/download/v${GOST_VERSION}/gost-${platform}-${GOST_VERSION}.gz"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local gzfile="${tmp_dir}/gost.gz"

  if ! curl -fSL "$url" -o "$gzfile" 2>/dev/null; then
    rm -rf "$tmp_dir"
    log_warn "  Failed to download gost"
    return 0
  fi

  if ! gzip -d "$gzfile"; then
    rm -rf "$tmp_dir"
    log_warn "  Failed to decompress gost"
    return 0
  fi

  mv "${tmp_dir}/gost" "$bin_path"
  rm -rf "$tmp_dir"
  chmod +x "$bin_path"

  log_success "  gost installed to ${bin_path}"
}

app_configure() {
  local app_dir="$HOME/app"
  ensure_dir "$app_dir"

  # 链接 run_gost 管理脚本
  link_file "$DOTFILES/scripts/run_gost" "$app_dir/run_gost"
}

app_post_install() {
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would start gost"
    return 0
  fi

  log_info "  Starting gost..."
  "$HOME/app/run_gost" start || log_warn "  Failed to start gost"
  log_info "  Gost is ready. Use '$HOME/app/run_gost {start|stop|status|logs}' to manage."
}
