#!/usr/bin/env bash
# 开发工具安装模块
# 安装开发环境：uv + Python 3.13 + Go（用户级）

PYTHON_VERSION="${PYTHON_VERSION:-3.13}"

# Go 最低版本要求
MIN_GO_VERSION="1.23.0"

uv_bin() {
  if command -v uv >/dev/null 2>&1; then
    command -v uv
    return 0
  fi
  if [[ -x "$HOME/.local/bin/uv" ]]; then
    printf '%s' "$HOME/.local/bin/uv"
    return 0
  fi
  return 1
}

get_go_version() {
  if command -v go >/dev/null 2>&1; then
    go version | grep -oP '\d+\.\d+\.\d+' | head -1
  else
    echo "0.0.0"
  fi
}

version_ge() {
  [[ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" == "$2" ]]
}

ensure_uv() {
  if uv_path="$(uv_bin)"; then
    log "✅ uv: already installed ($uv_path)"
    return 0
  fi

  log "📦 uv: installing..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: curl -fsSL https://astral.sh/uv/install.sh | sh -s -- --no-modify-path"
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
  else
    die "Need curl or wget to install uv"
  fi

  uv_path="$(uv_bin || true)"
  [[ -n "$uv_path" ]] || die "uv install failed"
  log "✅ uv: installed ($uv_path)"
}

ensure_python_313_via_uv() {
  local uv
  uv="$(uv_bin || true)"
  [[ -n "$uv" ]] || die "uv not found"

  if "$uv" python find "$PYTHON_VERSION" >/dev/null 2>&1; then
    log "✅ Python $PYTHON_VERSION: already installed via uv"
    return 0
  fi

  log "📦 Python $PYTHON_VERSION: installing via uv..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: $uv python install $PYTHON_VERSION"
  else
    "$uv" python install "$PYTHON_VERSION"
  fi
}

link_python_shims() {
  local uv
  uv="$(uv_bin || true)"
  [[ -n "$uv" ]] || die "uv not found"

  local py_path
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    py_path="$HOME/.local/share/uv/python/cpython-$PYTHON_VERSION/bin/python3"
  else
    py_path="$($uv python find "$PYTHON_VERSION")"
    [[ -x "$py_path" ]] || die "uv python path invalid: $py_path"
  fi

  ensure_dir "$HOME/.local/bin"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would link: $HOME/.local/bin/python -> $py_path"
    log "🧪 (dry-run) Would link: $HOME/.local/bin/python3 -> $py_path"
  else
    ln -sfn "$py_path" "$HOME/.local/bin/python"
    ln -sfn "$py_path" "$HOME/.local/bin/python3"
  fi
  log "✅ python/python3: linked to uv Python $PYTHON_VERSION"
}

ensure_nvim_python_provider() {
  local provider_dir="$HOME/.local/share/nvim/python-provider-3.13"
  local provider_python="$provider_dir/bin/python"
  local uv
  uv="$(uv_bin || true)"
  [[ -n "$uv" ]] || die "uv not found"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: $uv venv --python $PYTHON_VERSION $provider_dir"
    log "🧪 (dry-run) Would run: $uv pip install --python $provider_python --upgrade pynvim"
    return 0
  fi

  if [[ ! -x "$provider_python" ]]; then
    "$uv" venv --python "$PYTHON_VERSION" "$provider_dir"
  fi
  "$uv" pip install --python "$provider_python" --upgrade pynvim
  log "✅ nvim python provider: $provider_python"
}

cleanup_legacy_pyenv_profile() {
  local old_profile="$HOME/.profile.d/pyenv.sh"
  if [[ -L "$old_profile" || -f "$old_profile" ]]; then
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🧪 (dry-run) Would remove legacy profile: $old_profile"
    else
      rm -f "$old_profile"
    fi
    log "✅ removed legacy pyenv profile snippet"
  fi
}

# Go 安装（改为用户级 ~/.local/go）
ensure_go() {
  local current_go_version
  current_go_version=$(get_go_version)
  
  if version_ge "$current_go_version" "$MIN_GO_VERSION"; then
    log "✅ Go $current_go_version: already installed (≥ $MIN_GO_VERSION required)"
    return 0
  fi
  
  if [[ "$current_go_version" != "0.0.0" ]]; then
    log "⚠️  Go $current_go_version is too old (need ≥ $MIN_GO_VERSION)"
    log "   Upgrading Go..."
  else
    log "📦 Go: installing to ~/.local/go..."
  fi
  
  local go_version="1.23.6"
  local go_tar="go${go_version}.linux-amd64.tar.gz"
  # 使用阿里云镜像，国内访问更快更稳定
  local go_url="https://mirrors.aliyun.com/golang/${go_tar}"
  local tmp_dir=$(mktemp -d)
  
  log "   Downloading Go ${go_version}..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would download: $go_url"
  else
    # Use -f to fail on HTTP errors, --retry for transient failures
    log "   Downloading from: $go_url"
    local curl_output="${tmp_dir}/curl.log"
    if ! curl -fsL -A "Mozilla/5.0" --retry 3 --retry-delay 2 -o "${tmp_dir}/${go_tar}" "$go_url" 2>"$curl_output"; then
      log "   ❌ Download failed. Error output:"
      cat "$curl_output" | sed 's/^/      /' >&2
      rm -rf "$tmp_dir"
      die "Failed to download Go from $go_url"
    fi
    
    # Verify download succeeded and has reasonable size (> 10MB)
    local file_size
    file_size=$(stat -c%s "${tmp_dir}/${go_tar}" 2>/dev/null || stat -f%z "${tmp_dir}/${go_tar}" 2>/dev/null || echo 0)
    if [[ "$file_size" -lt 10000000 ]]; then
      rm -rf "$tmp_dir"
      die "Downloaded Go tarball is too small (${file_size} bytes), download may have failed"
    fi
    
    log "   Download complete ($(numfmt --to=iec "$file_size" 2>/dev/null || echo "${file_size}" bytes))"
  fi
  
  log "   Extracting to ~/.local/go..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would extract to ~/.local/go"
  else
    rm -rf "$HOME/.local/go"
    mkdir -p "$HOME/.local"
    tar -C "$HOME/.local" -xzf "${tmp_dir}/${go_tar}"
    mv "$HOME/.local/go" "$HOME/.local/go.tmp"
    mv "$HOME/.local/go.tmp" "$HOME/.local/go"
  fi
  rm -rf "$tmp_dir"
  
  # 添加到 PATH（通过 profile.d）
  if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
    export PATH="$HOME/.local/go/bin:$PATH"
  fi
  
  log "✅ Go $(get_go_version): installed successfully"
}

# Go 的 profile.d 配置
link_go_profile() {
  local src="${DOTFILES:?}/home/profile.d/go.sh"
  local dst_dir="$HOME/.profile.d"
  local dst="$dst_dir/go.sh"
  
  # 创建 go.sh（如果不存在）
  if [[ ! -f "$src" ]]; then
    mkdir -p "$(dirname "$src")"
    cat > "$src" << 'EOF'
# Go configuration
if [ -d "$HOME/.local/go/bin" ]; then
  export PATH="$HOME/.local/go/bin:$PATH"
fi
EOF
  fi
  
  ensure_dir "$dst_dir"
  link_one "$src" "$dst"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  dev-tools disabled"; return 0; }
  
  log "🔧 Installing development tools..."
  
  # 检查是否在 Ubuntu/Debian
  if ! command -v apt-get >/dev/null 2>&1; then
    log "⚠️  This module requires apt-get (Ubuntu/Debian)"
    return 0
  fi
  
  # 1. 安装 unzip（基础依赖）
  if ! command -v unzip >/dev/null 2>&1; then
    log "📦 unzip: installing..."
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🧪 (dry-run) Would run: sudo apt-get install -y unzip"
    else
      sudo apt-get update -qq
      sudo apt-get install -y -qq unzip
    fi
  else
    log "  ✅ unzip: already installed"
  fi

  # 2. 安装 uv + Python 3.13
  log ""
  log "📦 Setting up Python via uv..."
  ensure_uv
  ensure_python_313_via_uv
  link_python_shims
  ensure_nvim_python_provider
  cleanup_legacy_pyenv_profile

  # 3. 安装 Go（用户级）
  log ""
  log "📦 Setting up Go..."
  ensure_go
  link_go_profile
  
  log ""
  log "✅ Development tools setup complete"
  log ""
  log "ℹ️  Important: Run 'source ~/.profile' or open a new terminal to use uv and Go"
  log "ℹ️  Python: python --version (should show 3.13.x)"
  log "ℹ️  Go: go version"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
