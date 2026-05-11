#!/usr/bin/env bash
# tmux_layout.sh - 自动创建 3 分屏布局
# 结构:
#   +-------+--------------------+
#   |       |                    |
#   | 辅助   |      主窗口         |
#   | 20%   |       (右上)        |
#   |       |                    |
#   +-------+--------------------+
#   |       命令行窗口 10%        |
#   +----------------------------+

set -euo pipefail

# 检查是否在 tmux 中
in_tmux() {
  [[ -n "${TMUX:-}" ]]
}

# 确保在 tmux session 中
ensure_tmux_session() {
  local session_name="${1:-my-session}"
  
  if ! in_tmux; then
    echo "Not in tmux session, creating new session: $session_name"
    tmux new-session -d -s "$session_name"
    tmux send-keys -t "$session_name" "$(realpath "$0")" C-m
    tmux attach -t "$session_name"
    exit 0
  fi
}

# 应用 3 分布局
apply_layout() {
  local width height
  width=$(tmux display-message -p '#{window_width}')
  height=$(tmux display-message -p '#{window_height}')
  
  echo "Current window size: ${width}x${height}"
  
  # 清除现有布局（保留第一个 pane）
  tmux kill-pane -a 2>/dev/null || true
  
  # 1. 垂直分割：左侧辅助窗口(20%)，右侧主区域(80%)
  local left_width=$((width * 20 / 100))
  tmux split-window -h -l "$left_width"
  
  # 此时：pane 0 = 右侧主区域, pane 1 = 左侧辅助窗口
  
  # 2. 在右侧主区域(pane 0)水平分割：上方主窗口，下方命令行窗口(10%)
  local bottom_height=$((height * 10 / 100))
  tmux split-window -v -l "$bottom_height" -t 0
  
  # 此时：pane 0 = 主窗口, pane 1 = 左侧辅助窗口, pane 2 = 命令行窗口
  
  # 选择主窗口
  tmux select-pane -t 0
  
  echo "Layout applied!"
  echo "  Pane 0: 主窗口 (右上)"
  echo "  Pane 1: 辅助窗口 (左侧)"
  echo "  Pane 2: 命令行窗口 (底部)"
}

# 显示帮助
show_help() {
  cat << 'EOF'
Usage: ./tmux_layout.sh [SESSION_NAME]

创建一个 3 分屏布局：左侧辅助窗口 + 右上主窗口 + 底部命令行窗口

Examples:
  # 在当前 tmux session 应用布局
  ./tmux_layout.sh

  # 创建新 session 并应用布局
  ./tmux_layout.sh my-project
EOF
}

main() {
  local session_name="${1:-layout-session}"
  
  case "$session_name" in
    -h|--help)
      show_help
      exit 0
      ;;
  esac
  
  ensure_tmux_session "$session_name"
  
  echo "Applying 3-pane layout..."
  apply_layout
}

main "$@"
