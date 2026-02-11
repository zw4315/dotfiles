#!/usr/bin/env bash

# This file assumes `lib/common.sh` has already been sourced.

# Input: list of "command=apt-package" pairs.
# Output: missing apt package names, one per line.
apt_missing_pkgs() {
  if ! command -v apt-get >/dev/null 2>&1; then
    die "apt-get not found. This profile requires Debian/Ubuntu (apt) or a different installer."
  fi

  local missing_pkgs=()
  local pair cmd pkg
  for pair in "$@"; do
    cmd="${pair%%=*}"
    pkg="${pair#*=}"
    command -v "$cmd" >/dev/null 2>&1 && continue
    missing_pkgs+=("$pkg")
  done

  printf '%s\n' "${missing_pkgs[@]}"
}

apt_install_pkgs() {
  if ! command -v apt-get >/dev/null 2>&1; then
    die "apt-get not found. This profile requires Debian/Ubuntu (apt) or a different installer."
  fi
  command -v sudo >/dev/null 2>&1 || die "sudo not found. Install packages as root or install sudo."
  ((${#@} == 0)) && return 0
  sudo apt-get install -y "$@"
}
