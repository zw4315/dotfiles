# =============================================================================
# Homebrew PATH setup (macOS only)
# =============================================================================
# Ensures Homebrew binaries (e.g., universal-ctags) take precedence over
# system defaults like /usr/bin/ctags (BSD ctags).
# =============================================================================

if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi
