#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# shellcheck source=/dev/null
source "$DOTFILES/lib/common.sh"

# Preset 选择（默认 dev）
PRESET="dev"
DRY_RUN="${DRY_RUN:-0}"

show_brief_usage() {
  cat <<'EOF'
Usage: ./init.sh [PRESET] [options]

Presets:
  --min       最小安装 (core + editors + dev-env)
  --dev       开发完整 (默认)
  --full      全部安装

Run './init.sh --help' for full usage.
EOF
}

show_full_help() {
  cat <<'EOF'
Usage: ./init.sh [PRESET] [options]

Presets:
  --min       最小安装 (core + editors + dev-env)
  --dev       开发完整 (默认，包含 dev-tools)
  --full      全部安装 (包含可选组件)

Options:
  --dry-run   预览更改
  --help      显示帮助

Examples:
  ./init.sh --min           # 最小安装
  ./init.sh --dev           # 开发完整（默认）
  ./init.sh --full          # 全部安装
  ./init.sh --min --dry-run # 预览最小安装

Environment variables:
  DOTFILES             Dotfiles repo path (default: this directory)
  DOTFILES_PROFILE     Profile name (ubuntu|windows). Default: auto-detect
  DRY_RUN              1 to enable dry-run (same as --dry-run)
EOF
}

detect_os_profile() {
  local u
  u="$(uname -s 2>/dev/null || echo unknown)"
  case "$u" in
    Linux*) echo ubuntu ;;
    Darwin*) echo ubuntu ;; # treat all unix-like as ubuntu for now
    MINGW*|MSYS*|CYGWIN*) echo windows ;;
    *) echo ubuntu ;;
  esac
}

PROFILE_NAME="${DOTFILES_PROFILE:-$(detect_os_profile)}"
PROFILE_PATH="$DOTFILES/profiles/${PROFILE_NAME}.sh"

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --min|--minimal) PRESET="minimal"; shift ;;
    --dev|--develop) PRESET="dev"; shift ;;
    --full|--complete) PRESET="full"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help|-h) show_full_help; exit 0 ;;
    --*) 
      echo "Error: Unknown flag '$1'" >&2
      show_brief_usage >&2
      exit 1
      ;;
    *) 
      echo "Error: Unknown argument '$1'" >&2
      show_brief_usage >&2
      exit 1
      ;;
  esac
done

[[ -f "$PROFILE_PATH" ]] || die "Profile not found: $PROFILE_PATH"

load_os_profile() {
  # Ensure the function comes from the profile we load (not from the environment).
  unset -f dotfiles_profile_apply 2>/dev/null || true

  # shellcheck source=/dev/null
  source "$PROFILE_PATH"

  declare -F dotfiles_profile_apply >/dev/null 2>&1 \
    || die "Profile must define dotfiles_profile_apply(): $PROFILE_PATH"
}

run_module_entry() {
  local entry="$1"
  local name value script
  
  # 为了点兼容性，else 里写的是 格式1：只有模块名（默认启用，value=1）MODULES=(nvim git)
  if [[ "$entry" == *"="* ]]; then
    name="${entry%%=*}"
    value="${entry#*=}"
  else
    name="$entry"
    value="1"
  fi

  script="$DOTFILES/modules/${name}.sh"
  [[ -f "$script" ]] || die "Module script not found: $script"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    log "▶ module: $name=$value ($script)"
  else
    log "▶ module: $name=$value"
  fi

  # 这里的 () 更像一个 RAII
  (
    set -euo pipefail
    # Run each module in its own subshell:
    # - keeps modules isolated (no leaking options/functions)
    # - allows sharing helpers from lib/common.sh without re-sourcing in every module
    # shellcheck source=/dev/null
    source "$script"
    module_main "$value"
  )
}

# Apply profile configuration (kept here so the main flow reads top-to-bottom).
load_os_profile

MODULES=()
while IFS= read -r entry; do
  [[ -n "$entry" ]] && MODULES+=("$entry")
done < <(dotfiles_profile_apply "$PRESET")

log "Dotfiles: $DOTFILES"
log "Profile:  $PROFILE_NAME ($PROFILE_PATH)"
log "Preset:   $PRESET"
log "Dry-run:  $DRY_RUN"
if ((${#MODULES[@]} == 0)); then
  die "No modules enabled in profile: $PROFILE_PATH"
fi
log "Modules:  ${MODULES[*]}"

for entry in "${MODULES[@]}"; do
  run_module_entry "$entry"
done

log "✅ Dotfiles installation complete (preset: $PRESET)"
