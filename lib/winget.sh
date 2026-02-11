#!/usr/bin/env bash

# This file assumes `lib/common.sh` has already been sourced.

# Input: list of "command=wingetId" pairs.
# Installs only the wingetIds whose commands are missing.
winget_install_missing_cmds() {
  if ! command -v winget >/dev/null 2>&1; then
    die "winget not found. Install Winget, or install deps manually."
  fi

  local missing_ids=()
  local pair cmd wid
  for pair in "$@"; do
    cmd="${pair%%=*}"
    wid="${pair#*=}"
    command -v "$cmd" >/dev/null 2>&1 && continue
    missing_ids+=("$wid")
  done

  ((${#missing_ids[@]} == 0)) && { log "✅ packages: all installed"; return 0; }
  log "📦 packages: missing -> ${missing_ids[*]}"

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    for wid in "${missing_ids[@]}"; do
      log "🧪 (dry-run) Would run: winget install --id $wid -e --accept-package-agreements --accept-source-agreements"
    done
    return 0
  fi

  local wid
  for wid in "${missing_ids[@]}"; do
    winget install --id "$wid" -e --accept-package-agreements --accept-source-agreements
  done
}
