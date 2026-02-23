#!/usr/bin/env bash
# 40-system.sh - 系统工具模块
# 配置系统环境：bash, tmux, zoxide, scripts

# Bash 配置
setup_bash() {
  local bashrc_src="$DOTFILES/home/bashrc"
  local profile_src="$DOTFILES/home/profile"
  local aliases_src="$DOTFILES/home/bash_aliases"
  local proxy_src="$DOTFILES/home/proxyrc"
  local mihd_src="$DOTFILES/home/bash_aliases_mihd"

  [[ -f "$bashrc_src" ]] || die "bashrc not found: $bashrc_src"
  [[ -f "$aliases_src" ]] || die "bash_aliases not found: $aliases_src"
  [[ -f "$proxy_src" ]] || die "proxyrc not found: $proxy_src"
  [[ -f "$profile_src" ]] || die "profile not found: $profile_src"

  link_one "$bashrc_src" "$HOME/.bashrc"
  link_one "$profile_src" "$HOME/.profile"
  link_one "$aliases_src" "$HOME/.bash_aliases"
  link_one "$proxy_src" "$HOME/.proxyrc"
  
  # 可选：mihomo 代理管理 alias（如果不存在则跳过）
  if [[ -f "$mihd_src" ]]; then
    link_one "$mihd_src" "$HOME/.bash_aliases_mihd"
  fi

  log "✅ bash: configuration linked"
}

# Tmux
version_ge() {
  local have="$1"
  local need="$2"
  [[ -n "$have" && -n "$need" ]] || return 1
  [[ "$(printf '%s\n%s\n' "$need" "$have" | sort -V | head -n1)" == "$need" ]]
}

tmux_version() {
  command -v tmux >/dev/null 2>&1 || return 1
  tmux -V 2>/dev/null | awk '{print $2}'
}

ensure_tmux() {
  local min_version="${TMUX_MIN_VERSION:-3.3}"
  local desired_version="${TMUX_SOURCE_VERSION:-3.4}"

  local have=""
  have="$(tmux_version || true)"
  if [[ -n "$have" ]] && version_ge "$have" "$min_version"; then
    log "✅ tmux: version ok (v$have)"
    return 0
  fi

  log "📦 tmux: need >= v${min_version} (have: ${have:-none})"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/tmux.sh"
  module_main 1
}

# Zoxide
ensure_zoxide() {
  command -v zoxide >/dev/null 2>&1 && { log "✅ zoxide: already installed"; return 0; }

  log "📦 zoxide: installing"
  # shellcheck source=/dev/null
  source "${DOTFILES:?}/modules/zoxide.sh"
  module_main 1
}

# Scripts（链接到 ~/.local/bin）
link_scripts() {
  local src_dir="${DOTFILES:?}/scripts"
  local dst_dir="$HOME/.local/bin"

  [[ -d "$src_dir" ]] || die "scripts directory not found: $src_dir"
  ensure_dir "$dst_dir"

  for script in "$src_dir"/*; do
    [[ -e "$script" ]] || continue
    [[ -f "$script" ]] || continue
    [[ -x "$script" ]] || continue
    local name
    name="$(basename "$script")"
    link_one "$script" "$dst_dir/$name"
  done

  log "✅ scripts: linked to ~/.local/bin"
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  system disabled"; return 0; }

  log "🔧 Setting up system tools..."
  setup_bash
  ensure_tmux
  ensure_zoxide
  link_scripts
  log "✅ System tools configured"
  log "ℹ️  bash: restart your shell (or re-source ~/.bashrc) to apply changes"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
