#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# shellcheck source=/dev/null
source "$DOTFILES/lib/common.sh"

usage() {
  cat <<'EOF'
Usage:
  ./init.sh [options]

Options:
  --dry-run            Print actions without changing files
  -h, --help           Show this help

Environment variables (optional):
  DOTFILES             Dotfiles repo path (default: this directory)
  DOTFILES_PROFILE     Profile name (ubuntu|windows). Default: auto-detect
  DRY_RUN              1 to enable dry-run (same as --dry-run)

Profiles:
  Each profile defines `dotfiles_profile_apply`, which prints enabled modules
  to stdout (one per line), e.g.:
    nvim=1
    legacy=0
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
DRY_RUN="${DRY_RUN:-0}"

PROFILE_PATH="$DOTFILES/profiles/${PROFILE_NAME}.sh"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      usage >&2
      die "Unknown option: $1"
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
done < <(dotfiles_profile_apply)

log "Dotfiles: $DOTFILES"
log "Profile:  $PROFILE_NAME ($PROFILE_PATH)"
log "Dry-run:  $DRY_RUN"
if ((${#MODULES[@]} == 0)); then
  die "No modules enabled in profile: $PROFILE_PATH"
fi
log "Modules:  ${MODULES[*]}"

for entry in "${MODULES[@]}"; do
  run_module_entry "$entry"
done
