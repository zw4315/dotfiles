#!/usr/bin/env bash
# 开发工具安装模块
# 安装开发环境：pyenv (Python 3.13), Go (用户级)

# Python 默认版本
PYTHON_VERSION="${PYTHON_VERSION:-3.13.0}"

# Go 最低版本要求
MIN_GO_VERSION="1.23.0"

# pyenv 编译 Python 所需的系统依赖
PYENV_BUILD_DEPS=(
  make
  build-essential
  libssl-dev
  zlib1g-dev
  libbz2-dev
  libreadline-dev
  libsqlite3-dev
  wget
  curl
  llvm
  libncursesw5-dev
  xz-utils
  tk-dev
  libxml2-dev
  libxmlsec1-dev
  libffi-dev
  liblzma-dev
  git
)

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

# 安装 pyenv 编译依赖
ensure_pyenv_build_deps() {
  log "📦 pyenv: checking build dependencies..."
  
  local missing_deps=()
  for dep in "${PYENV_BUILD_DEPS[@]}"; do
    if ! dpkg -l | grep -q "^ii  $dep "; then
      missing_deps+=("$dep")
    fi
  done
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    log "📦 Installing missing dependencies: ${missing_deps[*]}"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🧪 (dry-run) Would run: sudo apt-get install -y ${missing_deps[*]}"
    else
      sudo apt-get update -qq
      sudo apt-get install -y -qq "${missing_deps[@]}"
    fi
  else
    log "  ✅ All build dependencies installed"
  fi
}

# 安装 pyenv
ensure_pyenv() {
  if [[ -d "$HOME/.pyenv" ]]; then
    log "✅ pyenv: already installed"
  else
    log "📦 pyenv: installing..."
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🧪 (dry-run) Would run: curl https://pyenv.run | bash"
    else
      curl https://pyenv.run | bash
    fi
  fi
  
  # 立即启用 pyenv（当前会话）
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
  fi
  
  log "✅ pyenv: ready"
}

# 通过 pyenv 安装 Python
ensure_python() {
  # 检查是否已安装该版本
  if [[ -d "$HOME/.pyenv/versions/$PYTHON_VERSION" ]]; then
    log "✅ Python $PYTHON_VERSION: already installed"
  else
    ensure_pyenv_build_deps
    log "📦 Python $PYTHON_VERSION: installing via pyenv..."
    log "   This may take 5-10 minutes..."
    
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "🧪 (dry-run) Would run: pyenv install $PYTHON_VERSION"
    else
      pyenv install "$PYTHON_VERSION"
    fi
  fi
  
  # 设置为全局默认
  if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
    pyenv global "$PYTHON_VERSION"
  fi
  log "✅ Python $PYTHON_VERSION: set as global default"
  
  # 验证
  if [[ "${DRY_RUN:-0}" -eq 0 ]]; then
    python --version
  fi
}

# 链接 pyenv 的 profile.d 配置
link_pyenv_profile() {
  local src="${DOTFILES:?}/home/profile.d/pyenv.sh"
  local dst_dir="$HOME/.profile.d"
  local dst="$dst_dir/pyenv.sh"
  
  [[ -f "$src" ]] || die "pyenv profile snippet not found: $src"
  ensure_dir "$dst_dir"
  link_one "$src" "$dst"
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
  local go_url="https://go.dev/dl/${go_tar}"
  local tmp_dir=$(mktemp -d)
  
  log "   Downloading Go ${go_version}..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would download: $go_url"
  else
    curl -sL "$go_url" -o "${tmp_dir}/${go_tar}"
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
  
  # 2. 安装 pyenv + Python 3.13
  log ""
  log "📦 Setting up Python via pyenv..."
  ensure_pyenv
  ensure_python
  link_pyenv_profile
  
  # 3. 安装 Go（用户级）
  log ""
  log "📦 Setting up Go..."
  ensure_go
  link_go_profile
  
  log ""
  log "✅ Development tools setup complete"
  log ""
  log "ℹ️  Important: Run 'source ~/.profile' or open a new terminal to use pyenv and Go"
  log "ℹ️  Python: python --version (should show $PYTHON_VERSION)"
  log "ℹ️  Go: go version"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
