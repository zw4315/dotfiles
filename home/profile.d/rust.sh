# Rust (cargo) env: only load if installed
export DOTFILES_RUST_PROFILE_LOADED=1

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
