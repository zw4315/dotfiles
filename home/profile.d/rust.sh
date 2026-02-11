# Rust (cargo) env: only load if installed
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

