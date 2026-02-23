#!/usr/bin/env bash
# 开发工具安装模块
# 安装 nvim LSP 所需的系统依赖：unzip, Go

# Minimum required Go version for modern LSP tools
MIN_GO_VERSION="1.23.0"

# Get Go version and compare
get_go_version() {
  if command -v go &> /dev/null; then
    go version | grep -oP '\d+\.\d+\.\d+' | head -1
  else
    echo "0.0.0"
  fi
}

# Compare two version strings
version_ge() {
  [[ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" == "$2" ]]
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  dev-tools disabled"; return 0; }

  log "🔧 Installing development tools..."

  # Check if running on Ubuntu/Debian
  if ! command -v apt-get &> /dev/null; then
    log "⚠️  This module requires apt-get (Ubuntu/Debian)"
    return 0
  fi

  local -a packages=()

  # unzip: required by Mason to extract LSP servers
  if ! command -v unzip &> /dev/null; then
    packages+=("unzip")
    log "  📦 unzip (required by Mason)"
  fi

  if [[ ${#packages[@]} -gt 0 ]]; then
    log "🚀 Installing packages: ${packages[*]}"
    sudo apt-get update -qq
    sudo apt-get install -y -qq "${packages[@]}"
  fi

  # Go: required for goimports, gofumpt, gopls
  local current_go_version
  current_go_version=$(get_go_version)
  
  if version_ge "$current_go_version" "$MIN_GO_VERSION"; then
    log "✅ Go $current_go_version already installed (≥ $MIN_GO_VERSION required)"
  else
    if [[ "$current_go_version" != "0.0.0" ]]; then
      log "⚠️  Go $current_go_version is too old (need ≥ $MIN_GO_VERSION)"
      log "   Upgrading Go from official source..."
    else
      log "📦 Installing Go from official source..."
    fi
    
    # Install Go from official tarball (newer than apt)
    local go_version="1.23.6"
    local go_tar="go${go_version}.linux-amd64.tar.gz"
    local go_url="https://go.dev/dl/${go_tar}"
    local tmp_dir=$(mktemp -d)
    
    log "   Downloading Go ${go_version}..."
    curl -sL "$go_url" -o "${tmp_dir}/${go_tar}"
    
    log "   Extracting Go..."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "${tmp_dir}/${go_tar}"
    rm -rf "$tmp_dir"
    
    # Add to PATH if not already there
    if ! grep -q "/usr/local/go/bin" ~/.bashrc 2>/dev/null; then
      echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
      log "   Added Go to PATH in ~/.bashrc"
    fi
    
    # Export for current session
    export PATH=$PATH:/usr/local/go/bin
    
    log "✅ Go $(get_go_version) installed successfully"
  fi

  log "✅ Development tools setup complete"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
