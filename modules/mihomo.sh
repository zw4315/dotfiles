#!/usr/bin/env bash

ensure_mihomo() {
  if command -v mihomo >/dev/null 2>&1; then
    log "✅ mihomo: already installed"
    return 0
  fi

  local version="1.19.20"
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

  local bin_dir="${HOME}/.local/bin"
  local bin_path="${bin_dir}/mihomo"

  ensure_dir "$bin_dir"

  log "📦 mihomo: downloading v${version} (${os}-${arch})"
  
  local url="https://github.com/MetaCubeX/mihomo/releases/download/v${version}/mihomo-${os}-${arch}-v${version}.gz"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local gzfile="${tmp_dir}/mihomo.gz"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🌐 (dry-run) Download: $url"
    log "📁 (dry-run) Extract to: $bin_path"
    rm -rf "$tmp_dir"
    return 0
  fi

  curl -fSL "$url" -o "$gzfile" || {
    rm -rf "$tmp_dir"
    die "Failed to download mihomo"
  }

  gzip -d "$gzfile" || {
    rm -rf "$tmp_dir"
    die "Failed to decompress mihomo"
  }

  mv "${tmp_dir}/mihomo" "$bin_path" || {
    rm -rf "$tmp_dir"
    die "Failed to install mihomo"
  }

  rm -rf "$tmp_dir"
  chmod +x "$bin_path"

  if [[ ":$PATH:" != *":${bin_dir}:"* ]]; then
    log "⚠️  Add ${bin_dir} to PATH in your shell config"
  fi

  log "✅ mihomo: installed to ${bin_path}"
}

ensure_mihomo_config() {
  local config_dir="${HOME}/.config/mihomo"
  local config_file="${config_dir}/config.yaml"

  ensure_dir "$config_dir"

  if [[ -f "$config_file" ]]; then
    log "✅ mihomo config: already exists"
    return 0
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "📄 (dry-run) Create config: $config_file"
    return 0
  fi

  cat > "$config_file" <<'EOF'
# mihomo configuration

# HTTP proxy port
port: 7890

# SOCKS5 proxy port
socks-port: 7891

# Enable redirect to proxy
# redir-port: 7892

# Enable TUN mode (requires root)
# tun:
#   enable: true
#   stack: system
#   dns-hijack:
#     - 8.8.8.8
#     - 8.8.4.4

# Allow other devices to connect
# bind-address: "*"

# Log level
log-level: info

# External controller
# external-controller: 127.0.0.1:9090

# Proxies
# proxies:
#   - name: "example"
#     type: ss
#     server: example.com
#     port: 443
#     cipher: aes-256-gcm
#     password: password

# Proxy groups
# proxy-groups:
#   - name: "auto"
#     type: select
#     proxies:
#       - DIRECT
#       - example

# Rules
# rules:
#   - MATCH,auto
EOF

  log "✅ mihomo config: created at ${config_file}"
  log "📝 Edit ${config_file} to add your nodes"
}

ensure_mihomo_config() {
  local template="$DOTFILES/config/mihomo/config.yaml"
  local config_dir="$HOME/.config/mihomo"
  local dst="${config_dir}/config.yaml"

  [[ -f "$template" ]] || die "mihomo template not found: $template"

  ensure_dir "$config_dir"

  if [[ -f "$dst" ]]; then
    # 检查是否是有效的代理配置（不是模板）
    if grep -q "proxy-providers:" "$dst" 2>/dev/null && ! grep -q "proxy-providers:" "$dst" | grep -q "^#"; then
      log "✅ mihomo config already exists: ${dst}"
    else
      log "⚠️  mihomo config exists but may be template (no proxy-providers configured)"
      log "   To add subscription, edit: ${dst}"
    fi
    return 0
  fi

  # 首次安装：复制模板
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "📄 (dry-run) Would copy config: ${template} -> ${dst}"
  else
    cp "$template" "$dst"
    log "📄 Copied mihomo config: ${dst}"
    log ""
    log "╔════════════════════════════════════════════════════════════════╗"
    log "║  ⚠️  MIHOMO: EDIT CONFIG REQUIRED                             ║"
    log "╠════════════════════════════════════════════════════════════════╣"
    log "║  Config copied, but you need to add your subscription URL:    ║"
    log "║                                                                ║"
    log "║    vim ${dst}"                                               
    log "║                                                                ║"
    log "║  Look for: url: \"YOUR_SUBSCRIPTION_URL_HERE\"                 ║"
    log "║  Replace with your actual subscription link.                  ║"
    log "╚════════════════════════════════════════════════════════════════╝"
    log ""
  fi
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  mihomo disabled"; return 0; }
  ensure_mihomo
  ensure_mihomo_config
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
