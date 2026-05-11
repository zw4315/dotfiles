#!/usr/bin/env bash
# =============================================================================
# App: Python (via uv)
# =============================================================================
# 通过 uv 安装 Python 3.13，并配置 Neovim Python provider。
# =============================================================================

APP_NAME="python"
APP_DESC="Python programming language (via uv)"
APP_DEPS=()

PYTHON_VERSION="${PYTHON_VERSION:-3.13}"

_uv_bin() {
  if has_cmd uv; then
    command -v uv
    return 0
  fi
  if [[ -x "$HOME/.local/bin/uv" ]]; then
    printf '%s' "$HOME/.local/bin/uv"
    return 0
  fi
  return 1
}

_ensure_uv() {
  local uv_path
  if uv_path="$(_uv_bin)"; then
    log_info "  Already installed: uv ($uv_path)"
    return 0
  fi

  log "  Installing uv..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would install uv"
    return 0
  fi

  if has_cmd curl; then
    curl -fsSL https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
  elif has_cmd wget; then
    wget -qO- https://astral.sh/uv/install.sh | sh -s -- --no-modify-path
  else
    die "Need curl or wget to install uv"
  fi

  uv_path="$(_uv_bin || true)"
  [[ -n "$uv_path" ]] || die "uv install failed"
  log_success "  uv installed"
}

_ensure_python() {
  local uv
  uv="$(_uv_bin || true)"
  [[ -n "$uv" ]] || die "uv not found"

  if "$uv" python find "$PYTHON_VERSION" >/dev/null 2>&1; then
    log_info "  Already installed: Python $PYTHON_VERSION via uv"
    return 0
  fi

  log "  Installing Python $PYTHON_VERSION via uv..."
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would run: uv python install $PYTHON_VERSION"
    return 0
  fi

  "$uv" python install "$PYTHON_VERSION"
  log_success "  Python $PYTHON_VERSION installed"
}

_link_python_shims() {
  local uv
  uv="$(_uv_bin || true)"
  [[ -n "$uv" ]] || die "uv not found"

  local py_path
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    py_path="$HOME/.local/share/uv/python/cpython-${PYTHON_VERSION}-linux-x86_64/bin/python3"
  else
    py_path="$($uv python find "$PYTHON_VERSION")"
    [[ -x "$py_path" ]] || die "uv python path invalid: $py_path"
  fi

  ensure_dir "$HOME/.local/bin"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would link python/python3 -> $py_path"
    return 0
  fi

  ln -sfn "$py_path" "$HOME/.local/bin/python"
  ln -sfn "$py_path" "$HOME/.local/bin/python3"
  log_success "  python/python3 linked to uv Python $PYTHON_VERSION"
}

_ensure_nvim_python_provider() {
  local provider_dir="$HOME/.local/share/nvim/python-provider-${PYTHON_VERSION}"
  local provider_python="$provider_dir/bin/python"
  local uv
  uv="$(_uv_bin || true)"
  [[ -n "$uv" ]] || die "uv not found"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "  [dry-run] Would setup nvim python provider"
    return 0
  fi

  if [[ ! -x "$provider_python" ]]; then
    "$uv" venv --python "$PYTHON_VERSION" "$provider_dir"
  fi
  "$uv" pip install --python "$provider_python" --upgrade pynvim
  log_success "  nvim python provider configured"
}

app_install() {
  _ensure_uv
  _ensure_python
  _link_python_shims
  _ensure_nvim_python_provider
}

app_configure() {
  # 清理旧 pyenv profile
  local old_profile="$HOME/.profile.d/pyenv.sh"
  if [[ -L "$old_profile" || -f "$old_profile" ]]; then
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "  [dry-run] Would remove legacy pyenv profile: $old_profile"
    else
      rm -f "$old_profile"
      log_info "  Removed legacy pyenv profile snippet"
    fi
  fi
}

app_post_install() {
  if has_cmd python3; then
    log_info "  Python configured. Try: python3 --version"
  fi
  log_info "  Tip: Run 'source ~/.profile' or open a new terminal to use uv"
}
