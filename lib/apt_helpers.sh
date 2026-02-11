#!/usr/bin/env bash

# Helpers for Debian/Ubuntu apt-based installs.
# Assumes `lib/common.sh` has already been sourced (log/die/is_enabled/ensure_dir/link_one).

dotfiles_apt_require() {
  command -v apt-get >/dev/null 2>&1 || die "apt-get not found; this module requires Debian/Ubuntu (apt)"
  command -v sudo >/dev/null 2>&1 || die "sudo not found; install packages as root or install sudo"
}

dotfiles_apt_update_once() {
  dotfiles_apt_require

  local stamp="/tmp/dotfiles-apt-updated-${UID:-0}"
  if [[ -f "$stamp" ]]; then
    return 0
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: sudo apt-get update"
    return 0
  fi

  sudo apt-get update
  : >"$stamp" || true
}

dotfiles_apt_install_pkgs() {
  dotfiles_apt_require
  ((${#@} == 0)) && return 0

  dotfiles_apt_update_once

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: sudo apt-get install -y $*"
    return 0
  fi

  sudo apt-get install -y "$@"
}

dotfiles_apt_try_install_pkgs() {
  dotfiles_apt_require
  ((${#@} == 0)) && return 0

  dotfiles_apt_update_once

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: sudo apt-get install -y $*"
    return 0
  fi

  sudo apt-get install -y "$@"
}

dotfiles_apt_ensure_cmd() {
  local cmd="$1"
  local pkg="${2:-$1}"
  command -v "$cmd" >/dev/null 2>&1 && return 0
  dotfiles_apt_install_pkgs "$pkg"
  command -v "$cmd" >/dev/null 2>&1 || die "$cmd install failed (missing after apt): $cmd"
}

dotfiles_apt_try_ensure_cmd() {
  local cmd="$1"
  local pkg="${2:-$1}"
  command -v "$cmd" >/dev/null 2>&1 && return 0
  dotfiles_apt_try_install_pkgs "$pkg" || return $?
  command -v "$cmd" >/dev/null 2>&1
}

