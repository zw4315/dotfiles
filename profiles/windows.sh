#!/usr/bin/env bash

# Windows profile placeholder.
# Add modules here later (powershell profile, git, terminal, etc.).

dotfiles_profile_apply() {
  # Optional: Windows deps via winget (command -> winget Id)
  # WINGET_DEPS=(
  #   nvim=Neovim.Neovim
  #   rg=BurntSushi.ripgrep.MSVC
  #   git=Git.Git
  # )

  # Keep init.sh happy while the Windows profile is still a placeholder.
  cat <<'EOF'
legacy=0
EOF
}
