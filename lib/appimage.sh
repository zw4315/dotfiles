#!/usr/bin/env bash

# This file assumes `lib/common.sh` has already been sourced.

version_ge() {
  local have="$1"
  local need="$2"
  [[ -n "$have" && -n "$need" ]] || return 1
  [[ "$(printf '%s\n%s\n' "$need" "$have" | sort -V | head -n1)" == "$need" ]]
}

cmd_version() {
  # Best-effort semver extractor.
  # Uses VERSION_PATTERNS[cmd]=<sed-regex> if defined, else tries the common "vX.Y.Z" pattern.
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || return 1

  local raw
  raw="$("$cmd" --version 2>/dev/null | head -n1 || true)"
  [[ -n "$raw" ]] || return 1

  if declare -p VERSION_PATTERNS >/dev/null 2>&1; then
    local pat=""
    local pair k v
    for pair in "${VERSION_PATTERNS[@]}"; do
      k="${pair%%=*}"
      v="${pair#*=}"
      if [[ "$k" == "$cmd" ]]; then
        pat="$v"
        break
      fi
    done
    if [[ -n "$pat" ]]; then
      echo "$raw" | sed -n "s/${pat}/\\1/p"
      return 0
    fi
  fi

  echo "$raw" | sed -n 's/.*v\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p'
}

appimage_url_latest() {
  local repo="$1"  # e.g. neovim/neovim
  local asset="$2" # e.g. nvim-linux-x86_64.appimage
  printf 'https://github.com/%s/releases/latest/download/%s' "$repo" "$asset"
}

appimage_asset_for_arch() {
  local asset_x86_64="$1"
  local asset_arm64="$2"

  local arch
  arch="$(uname -m 2>/dev/null || echo unknown)"
  case "$arch" in
    x86_64|amd64) printf '%s' "$asset_x86_64" ;;
    aarch64|arm64) printf '%s' "$asset_arm64" ;;
    *) die "Unsupported arch for AppImage install: $arch" ;;
  esac
}

appimage_install_cmd() {
  local cmd="$1"
  local repo="$2"
  local asset_x86_64="$3"
  local asset_arm64="$4"

  local asset url
  asset="$(appimage_asset_for_arch "$asset_x86_64" "$asset_arm64")"
  url="$(appimage_url_latest "$repo" "$asset")"

  local dst_dir="$HOME/.local/bin"
  local dst="$dst_dir/$cmd"

  ensure_dir "$dst_dir"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🧪 (dry-run) Would download: $url -> $dst"
    log "🧪 (dry-run) Would chmod +x: $dst"
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --retry-delay 1 "$url" -o "$dst"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$dst" "$url"
  else
    die "Need curl or wget to download AppImage for $cmd"
  fi
  chmod +x "$dst"

  log "✅ Installed $cmd -> $dst"
  log "ℹ️  Verify with: $dst --version"

  if ! echo "${PATH:-}" | grep -q "$dst_dir"; then
    log 'ℹ️  Tip: add to your shell rc: export PATH="$HOME/.local/bin:$PATH"'
  fi

  # If PATH prefers another binary (e.g. /usr/bin/nvim), tell the user explicitly.
  local found=""
  found="$(command -v "$cmd" 2>/dev/null || true)"
  if [[ -n "$found" && "$found" != "$dst" ]]; then
    log "ℹ️  Note: current \`$cmd\` resolves to: $found"
    log "ℹ️  To use the AppImage now: $dst"
    log "ℹ️  If you updated PATH, run: hash -r  (or restart your shell)"
  fi
}

# Input: list of "cmd=repo:asset_x86_64:asset_arm64" pairs.
# Optional: MIN_VERSIONS=(cmd=0.11.2 ...) and VERSION_PATTERNS=(cmd='regex' ...)
appimage_ensure() {
  local pair cmd spec repo assets asset_x86 asset_arm need have
  for pair in "$@"; do
    cmd="${pair%%=*}"
    spec="${pair#*=}"

    repo="${spec%%:*}"
    assets="${spec#*:}"
    asset_x86="${assets%%:*}"
    asset_arm="${assets#*:}"

    need=""
    if declare -p MIN_VERSIONS >/dev/null 2>&1; then
      local mv k v
      for mv in "${MIN_VERSIONS[@]}"; do
        k="${mv%%=*}"
        v="${mv#*=}"
        [[ "$k" == "$cmd" ]] && need="$v"
      done
    fi

    if command -v "$cmd" >/dev/null 2>&1; then
      if [[ -n "$need" ]]; then
        have="$(cmd_version "$cmd" || true)"
        if [[ -n "$have" ]] && version_ge "$have" "$need"; then
          log "✅ $cmd: version ok (v$have)"
          continue
        fi
        log "📦 $cmd: ${have:+v$have }too old (need >= v$need)"
      else
        log "✅ $cmd: already installed"
        continue
      fi
    else
      log "📦 $cmd: not found${need:+ (need >= v$need)}"
    fi

    appimage_install_cmd "$cmd" "$repo" "$asset_x86" "$asset_arm"
  done
}
