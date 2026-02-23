#!/usr/bin/env bash

# Ubuntu profile: 使用预设配置
#
# 支持预设:
#   --min  (--minimal)   : 最小安装 (core + editors + dev-env)
#   --dev  (--develop)   : 开发完整 (默认，包含 dev-tools)
#   --full (--complete)  : 全部安装 (包含可选组件)
#
# 使用方式:
#   ./init.sh --min
#   ./init.sh --dev
#   ./init.sh --full

dotfiles_profile_apply() {
  local preset="${1:-dev}"
  
  case "$preset" in
    minimal|--min|--minimal)
      cat <<'EOF'
00-core=1
20-editors=1
30-dev-env=1
EOF
      ;;
    dev|--dev|--develop|default)
      cat <<'EOF'
00-core=1
10-dev-tools=1
20-editors=1
30-dev-env=1
40-system=1
EOF
      ;;
    full|--full|--complete)
      cat <<'EOF'
00-core=1
10-dev-tools=1
20-editors=1
30-dev-env=1
40-system=1
50-optional=1
EOF
      ;;
    *)
      # 默认使用 dev
      cat <<'EOF'
00-core=1
10-dev-tools=1
20-editors=1
30-dev-env=1
40-system=1
EOF
      ;;
  esac
}
