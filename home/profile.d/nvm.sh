# NVM (Node Version Manager) configuration
export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Use default node version (puts ~/.nvm/versions/node/.../bin before /usr/bin)
if command -v nvm >/dev/null 2>&1; then
  nvm use default >/dev/null 2>&1 || true
fi

[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
