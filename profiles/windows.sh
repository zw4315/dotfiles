#!/usr/bin/env bash

# Windows profile (minimal).
# Keep this file config-only and only list modules you want enabled on Windows.

dotfiles_profile_apply() {
  cat <<'EOF'
gitconfig=1
EOF
}
