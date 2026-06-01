# Go configuration
# 用户级安装到 ~/.local/go

if [ -d "$HOME/.local/go/bin" ]; then
  export PATH="$HOME/.local/go/bin:$PATH"
fi

# Go tools installed via `go install` (default GOPATH ~/go/bin)
if [ -d "$HOME/go/bin" ]; then
  export PATH="$HOME/go/bin:$PATH"
fi
