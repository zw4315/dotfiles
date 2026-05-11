#!/usr/bin/env bash
# =============================================================================
# App: Bash Shell Environment
# =============================================================================
# 跨平台的 bash 配置，包含 bashrc、profile、aliases、proxy helpers。
# =============================================================================

APP_NAME="bash"
APP_DESC="Bash shell configuration"
APP_DEPS=()

# Bash 是系统预装的，不需要通过包管理器安装
# APP_BREW_FORMULA=""
# APP_APT_PACKAGE=""

app_install() {
  # Bash 通常已预装，无需安装
  :
}

app_configure() {
  local config_dir="$APP_DIR/config"

  # 链接核心配置文件
  link_home_file "$config_dir/profile" ".profile"
  link_home_file "$config_dir/bashrc" ".bashrc"
  link_home_file "$config_dir/bash_aliases" ".bash_aliases"
  link_home_file "$config_dir/proxyrc" ".proxyrc"

  # macOS 默认 shell 为 zsh，同时链接 zsh 配置
  if [[ "${DETECTED_OS:-}" == "darwin" ]]; then
    link_home_file "$DOTFILES/home/zshrc" ".zshrc"
    link_home_file "$DOTFILES/home/zprofile" ".zprofile"
  fi

  # 链接 scripts/ 目录下的可执行脚本到 PATH
  ensure_dir "$HOME/.local/bin"
  local script
  for script in "$DOTFILES/scripts/"*; do
    [[ -f "$script" && -x "$script" ]] || continue
    local name
    name="$(basename "$script")"
    link_file "$script" "$HOME/.local/bin/$name"
  done

  # 确保 profile.d 目录存在（供其他应用注入环境变量）
  ensure_dir "$HOME/.profile.d"
}

app_post_install() {
  # 保护关键源文件：外部工具（如 zoxide）可能会向 ~/.bashrc / ~/.zshrc 追加内容，
  # 而这些是 symlink，实际会修改仓库源文件。设为只读可防止意外污染。
  local -a protected_files=(
    "$APP_DIR/config/bashrc"
    "$APP_DIR/config/bash_aliases"
    "$APP_DIR/config/proxyrc"
    "$APP_DIR/config/profile"
    "$DOTFILES/home/zshrc"
    "$DOTFILES/home/zprofile"
  )
  for f in "${protected_files[@]}"; do
    if [[ -f "$f" && -w "$f" ]]; then
      chmod -w "$f"
      log_info "  Protected (read-only): ${f#$DOTFILES/}"
    fi
  done

  log_info "  Bash configured. Restart your shell or run: source ~/.bashrc"
}
