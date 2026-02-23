#!/usr/bin/env bash
set -euo pipefail

log() { printf '%s\n' "$*"; }
die() { log "ERROR: $*" >&2; exit 1; }

is_enabled() {
  local v="${1:-1}"
  case "$v" in
    0|off|OFF|false|FALSE|no|NO) return 1 ;;
    *) return 0 ;;
  esac
}

ensure_dir() {
  local dir="$1"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "📁 (dry-run) Ensure dir: $dir"
    return 0
  fi
  mkdir -p "$dir"
}

link_one() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log "✅ $dst already linked"
    return 0
  fi

  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local backup="${dst}.backup.$(date +%s)"
    if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
      log "💾 (dry-run) Backup $dst -> $backup"
    else
      mv "$dst" "$backup"
      log "💾 Backup $dst"
    fi
  fi

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    log "🔗 (dry-run) Linked $dst → $src"
  else
    ln -sfn "$src" "$dst"
    log "🔗 Linked $dst → $src"
  fi
}

# 配置解析函数
declare -gA PACKAGE_GROUPS
declare -gA PRESETS_CONFIG

# 解析多行值的配置文件
# 格式: key=
#   value1
#   value2
parse_multiline_config() {
  local file="$1"
  local -n dest="$2"
  
  local current_key=""
  local current_values=""
  
  while IFS= read -r line || [[ -n "$line" ]]; do
    # 跳过注释和空行
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// /}" ]] && continue
    
    # 检查是否是新的 key= 行
    if [[ "$line" =~ ^[[:space:]]*([^=]+)=[[:space:]]*$ ]]; then
      # 保存之前的 key
      if [[ -n "$current_key" ]]; then
        dest["$current_key"]="$current_values"
      fi
      # 开始新的 key
      current_key="${BASH_REMATCH[1]}"
      current_key="${current_key// /}"  # 去除空格
      current_values=""
    elif [[ -n "$current_key" && "$line" =~ ^[[:space:]]+([^[:space:]].*)$ ]]; then
      # 这是值行（缩进开头）
      local value="${BASH_REMATCH[1]}"
      # 去除行尾注释
      value="${value%%#*}"
      # 去除首尾空格
      value="${value#"${value%%[![:space:]]*}"}"
      value="${value%"${value##*[![:space:]]}"}"
      
      if [[ -n "$value" ]]; then
        if [[ -z "$current_values" ]]; then
          current_values="$value"
        else
          current_values="$current_values $value"
        fi
      fi
    fi
  done < "$file"
  
  # 保存最后一个 key
  if [[ -n "$current_key" ]]; then
    dest["$current_key"]="$current_values"
  fi
}

# 加载包配置
load_package_config() {
  local pkg_file="${DOTFILES}/config/packages.conf"
  local preset_file="${DOTFILES}/config/presets.conf"
  
  if [[ ! -f "$pkg_file" ]]; then
    die "Package config not found: $pkg_file"
  fi
  
  if [[ ! -f "$preset_file" ]]; then
    die "Preset config not found: $preset_file"
  fi
  
  parse_multiline_config "$pkg_file" PACKAGE_GROUPS
  parse_multiline_config "$preset_file" PRESETS_CONFIG
}

# 获取预设包含的组列表
get_preset_groups() {
  local preset="$1"
  echo "${PRESETS_CONFIG[$preset]:-}"
}

# 获取组包含的包列表
get_group_packages() {
  local group="$1"
  echo "${PACKAGE_GROUPS[$group]:-}"
}

