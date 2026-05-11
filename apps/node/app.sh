#!/usr/bin/env bash
# =============================================================================
# App: Node.js (via nvm)
# =============================================================================
# 通过 nvm 安装 Node LTS，便于版本管理。
# =============================================================================

APP_NAME="node"
APP_DESC="Node.js JavaScript runtime (via nvm)"
APP_DEPS=()

# 不通过系统包管理器，而是通过 nvm 安装
NVM_VERSION="${NVM_VERSION:-v0.40.3}"

_ensure_nvm() {
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  local nvm_sh="$nvm_dir/nvm.sh"

  if [[ -s "$nvm_sh" ]]; then
    log_info "  Already installed: nvm"
    return 0
  fi

  log "  Installing nvm -> $nvm_dir..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would install nvm $NVM_VERSION"
    return 0
  fi

  local url="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"
  if has_cmd curl; then
    NVM_DIR="$nvm_dir" curl -fsSL "$url" | bash
  elif has_cmd wget; then
    NVM_DIR="$nvm_dir" wget -qO- "$url" | bash
  else
    die "Need curl or wget to install nvm"
  fi

  [[ -s "$nvm_sh" ]] || die "nvm install failed"
  log_success "  nvm installed"
}

_install_node_lts() {
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  local nvm_sh="$nvm_dir/nvm.sh"

  # shellcheck source=/dev/null
  export NVM_DIR="$nvm_dir"
  # shellcheck source=/dev/null
  [[ -s "$nvm_sh" ]] && . "$nvm_sh"

  if nvm ls --lts >/dev/null 2>&1 | grep -q "v22"; then
    log_info "  Already installed: Node LTS"
    return 0
  fi

  log "  Installing Node LTS..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would install Node LTS via nvm"
    return 0
  fi

  nvm install --lts
  nvm alias default lts/*
  log_success "  Node LTS installed"
}

app_install() {
  _ensure_nvm
  _install_node_lts
}

app_configure() {
  local profile_src="$DOTFILES/home/profile.d/nvm.sh"
  if [[ -f "$profile_src" ]]; then
    ensure_dir "$HOME/.profile.d"
    link_file "$profile_src" "$HOME/.profile.d/nvm.sh"
  fi
}

app_post_install() {
  if has_cmd node 2>/dev/null || compgen -G "$HOME/.nvm/versions/node/*/bin/node" >/dev/null 2>&1; then
    log_info "  Node configured. Try: node --version"
  fi
}
