# pyenv - Python 版本管理器配置
# 所有 Python 版本安装在 ~/.pyenv/versions/
# 完全用户级，无需 sudo

export PYENV_ROOT="$HOME/.pyenv"

# 将 pyenv 的 bin 和 shims 添加到 PATH
if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

# 初始化 pyenv（创建 shims）
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# python 命令默认指向 pyenv 的 Python 3（替代 python-is-python3）
# 这样输入 'python' 就会自动使用 pyenv 设置的版本
if [ -n "${BASH_VERSION:-}" ] && command -v pyenv >/dev/null 2>&1; then
  alias python='pyenv exec python'
fi
