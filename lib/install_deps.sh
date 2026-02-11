#!/usr/bin/env bash

# This file assumes:
# - `lib/common.sh` has already been sourced (log/die/is_enabled)
# - a profile has already been sourced (INSTALL_DEPS + platform deps arrays)

dotfiles_install_deps() {
  local profile="${1:-}"

  local mode="${INSTALL_DEPS:-auto}"
  is_enabled "$mode" || { log "⏭️  install_deps disabled"; return 0; }

  case "$profile" in
    ubuntu)
      if declare -p APPIMAGE_DEPS >/dev/null 2>&1 && ((${#APPIMAGE_DEPS[@]})); then
        # shellcheck source=/dev/null
        source "${DOTFILES:?}/lib/appimage.sh"
        appimage_ensure "${APPIMAGE_DEPS[@]}"
      fi

      if ! declare -p APT_DEPS >/dev/null 2>&1; then
        log "ℹ️  install_deps(ubuntu): no APT_DEPS defined (skip)"
        return 0
      fi
      if ((${#APT_DEPS[@]} == 0)); then
        log "ℹ️  install_deps(ubuntu): APT_DEPS empty (skip)"
        return 0
      fi

      # shellcheck source=/dev/null
      source "${DOTFILES:?}/lib/apt.sh"

      local missing_pkgs=()
      while IFS= read -r pkg; do
        [[ -n "$pkg" ]] && missing_pkgs+=("$pkg")
      done < <(apt_missing_pkgs "${APT_DEPS[@]}")

      if ((${#missing_pkgs[@]} == 0)); then
        log "✅ packages: all installed"
        return 0
      fi

      log "📦 packages: missing -> ${missing_pkgs[*]}"

      if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
        log "🧪 (dry-run) Would run: sudo apt-get update"
        log "🧪 (dry-run) Would run: sudo apt-get install -y ${missing_pkgs[*]}"
        return 0
      fi

      command -v sudo >/dev/null 2>&1 || die "sudo not found. Install packages as root or install sudo."
      sudo apt-get update
      apt_install_pkgs "${missing_pkgs[@]}"
      ;;

    windows)
      if ! declare -p WINGET_DEPS >/dev/null 2>&1; then
        log "ℹ️  install_deps(windows): no WINGET_DEPS defined (skip)"
        return 0
      fi
      if ((${#WINGET_DEPS[@]} == 0)); then
        log "ℹ️  install_deps(windows): WINGET_DEPS empty (skip)"
        return 0
      fi

      # shellcheck source=/dev/null
      source "${DOTFILES:?}/lib/winget.sh"
      winget_install_missing_cmds "${WINGET_DEPS[@]}"
      ;;

    *)
      log "ℹ️  install_deps: unsupported profile '$profile' (skip)"
      ;;
  esac
}
