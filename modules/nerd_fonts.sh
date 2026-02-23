#!/usr/bin/env bash
# Nerd Fonts 安装模块
# 解决 nvim 图标显示为 ? 的问题

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  nerd-fonts disabled"; return 0; }

  log "🔤 Installing Nerd Fonts..."

  # 检查是否已安装 Nerd Font
  if fc-list 2>/dev/null | grep -qiE "nerd|jetbrains.*mono|fira.*code|hack.*nf"; then
    log "✅ Nerd Fonts already installed"
    return 0
  fi

  # 下载 JetBrainsMono Nerd Font
  local version="v3.2.1"
  local font_name="JetBrainsMono"
  local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${font_name}.zip"
  local tmp_dir=$(mktemp -d)

  log "📦 Downloading ${font_name} Nerd Font..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsL "$font_url" -o "$tmp_dir/${font_name}.zip" || {
      log "⚠️  Failed to download font, skipping"
      rm -rf "$tmp_dir"
      return 0
    }
  else
    log "⚠️  curl not found, cannot download fonts"
    rm -rf "$tmp_dir"
    return 0
  fi

  log "📦 Extracting fonts..."
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$tmp_dir/${font_name}.zip" -d "$tmp_dir/fonts" 2>&1 || true
  else
    log "⚠️  unzip not found, cannot extract fonts"
    rm -rf "$tmp_dir"
    return 0
  fi

  # 安装到用户目录
  local font_dir="$HOME/.local/share/fonts"
  ensure_dir "$font_dir"

  local installed_count=0
  for font in "$tmp_dir/fonts"/*.ttf; do
    if [[ -f "$font" ]]; then
      cp "$font" "$font_dir/" 2>&1
      ((installed_count++))
    fi
  done

  rm -rf "$tmp_dir"

  if [[ $installed_count -gt 0 ]]; then
    # 刷新字体缓存
    if command -v fc-cache >/dev/null 2>&1; then
      fc-cache -fv "$font_dir" >/dev/null 2>&1
    fi
    log "✅ ${font_name} Nerd Font installed (${installed_count} fonts)"
    log "ℹ️  Please restart your terminal and select '${font_name} Nerd Font' in terminal preferences"
  else
    log "⚠️  No fonts were installed"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
