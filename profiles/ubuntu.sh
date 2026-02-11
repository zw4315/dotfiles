#!/usr/bin/env bash

# Ubuntu profile: user chooses modules by editing MODULES.
#
# Notes:
# - This file is sourced by `./init.sh` (it doesn't execute by itself).
# - `./init.sh` does an "install" phase first (APT_DEPS), then a "configure" phase (MODULES).

# For Debian/Ubuntu (apt): map "command" -> "package name"
# init.sh install phase installs missing commands by installing the mapped packages.
APT_DEPS=(
  rg=ripgrep
  fdfind=fd-find
  git=git
)

# AppImage deps (cmd=repo:asset_x86_64:asset_arm64)
APPIMAGE_DEPS=(
  nvim=neovim/neovim:nvim-linux-x86_64.appimage:nvim-linux-arm64.appimage
)

# Optional version gating (cmd=semver)
MIN_VERSIONS=(
  nvim=0.11.2
)

# Optional version extractors (sed regex; must capture version in group 1)
VERSION_PATTERNS=(
  nvim='^NVIM v\([0-9]\+\.[0-9]\+\.[0-9]\+\).*'
)

# auto: install missing deps; 0: never install deps
INSTALL_DEPS=auto

# 配置阶段
MODULES=(
  path=1
  nvim=1
  tmux=1
)
