# Go configuration
# 用户级安装到 ~/.local/go

if [ -d "$HOME/.local/go/bin" ]; then
  export PATH="$HOME/.local/go/bin:$PATH"
fi
