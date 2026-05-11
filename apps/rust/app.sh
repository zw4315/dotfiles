#!/usr/bin/env bash
# =============================================================================
# App: Rust (via rustup)
# =============================================================================
# 通过 rustup 安装 Rust 工具链。
# =============================================================================

APP_NAME="rust"
APP_DESC="The Rust programming language (via rustup)"
APP_DEPS=()

_ensure_rustup() {
  if has_cmd rustup; then
    log_info "  Already installed: rustup"
    return 0
  fi

  if [[ -x "$HOME/.cargo/bin/rustup" ]]; then
    log_info "  Already installed: rustup ($HOME/.cargo/bin/rustup)"
    return 0
  fi

  log "  Installing rustup..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would install rustup"
    return 0
  fi

  if has_cmd curl; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  elif has_cmd wget; then
    wget -qO- https://sh.rustup.rs | sh -s -- -y
  else
    die "Need curl or wget to install rustup"
  fi

  if ! has_cmd rustup && [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    die "rustup install failed"
  fi

  log_success "  rustup installed"
}

app_install() {
  _ensure_rustup
}

app_configure() {
  local profile_src="$DOTFILES/home/profile.d/rust.sh"
  if [[ -f "$profile_src" ]]; then
    ensure_dir "$HOME/.profile.d"
    link_file "$profile_src" "$HOME/.profile.d/rust.sh"
  fi
}

app_post_install() {
  if [[ -x "$HOME/.cargo/bin/rustc" ]]; then
    log_info "  Rust configured. Try: rustc --version"
  fi
  log_info "  Tip: Run 'source ~/.cargo/env' or open a new terminal"
}
