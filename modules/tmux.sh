#!/usr/bin/env bash

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
  log "📦 tmux: installing from source (v${desired_version}) -> \$HOME/.local/bin/tmux"

  local build_deps=(
    build-essential
    pkg-config
    libevent-dev
    libncurses-dev
    bison
  )

  local tar="tmux-${desired_version}.tar.gz"
  local url="https://github.com/tmux/tmux/releases/download/${desired_version}/${tar}"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would run: sudo apt-get update"
    log "🧪 (dry-run) Would run: sudo apt-get install -y ${build_deps[*]}"
    log "🧪 (dry-run) Would download: $url"
    log "🧪 (dry-run) Would build+install: ./configure --prefix=$HOME/.local && make && make install"
    return 0
  fi

  command -v apt-get >/dev/null 2>&1 || die "apt-get not found; cannot install tmux build deps"
  command -v sudo >/dev/null 2>&1 || die "sudo not found; cannot install tmux build deps"

  sudo apt-get update
  sudo apt-get install -y "${build_deps[@]}"

  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --retry-delay 1 "$url" -o "$tmp/$tar"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$tmp/$tar" "$url"
  else
    die "Need curl or wget to download tmux source"
  fi

  tar -C "$tmp" -xzf "$tmp/$tar"
  local src_dir="$tmp/tmux-${desired_version}"
  [[ -d "$src_dir" ]] || die "tmux source dir not found after extract: $src_dir"

  ( cd "$src_dir" && ./configure --prefix="$HOME/.local" && make -j"$(nproc 2>/dev/null || echo 2)" && make install )

  local installed="$HOME/.local/bin/tmux"
  [[ -x "$installed" ]] || die "tmux install failed (missing): $installed"

  have="$("$installed" -V 2>/dev/null | awk '{print $2}' || true)"
  if [[ -z "$have" ]] || ! version_ge "$have" "$min_version"; then
    die "tmux installed but version check failed (have: ${have:-unknown}, need: $min_version)"
  fi

  log "✅ tmux: installed $installed (v$have)"
  if ! echo "${PATH:-}" | grep -q "$HOME/.local/bin"; then
    log 'ℹ️  Tip: enable PATH module (or add): export PATH="$HOME/.local/bin:$PATH"'
  fi
}

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  tmux disabled"; return 0; }

  ensure_tmux

  local src="$DOTFILES/files/tmux.conf"
  local dst="$HOME/.tmux.conf"

  [[ -f "$src" ]] || die "tmux config not found: $src"
  link_one "$src" "$dst"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
