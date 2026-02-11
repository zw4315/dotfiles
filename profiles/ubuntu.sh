#!/usr/bin/env bash

# Ubuntu profile: user chooses modules by editing MODULES.
#
# Notes:
# - This file is sourced by `./init.sh` to load `dotfiles_profile_apply`.
# - `dotfiles_profile_apply` is the only exported API; keep this file config-only.

dotfiles_profile_apply() {
  cat <<'EOF'
bash=1
scripts=1
curl=1
wget=1
git=1
gitconfig=1
rg=1
fd=1
global=1
vim=1
nvim=1
tmux=1
zoxide=1
nvm=1
EOF
}
