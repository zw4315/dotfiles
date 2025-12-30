#!/bin/bash

# Utils for dotfiles setup

link_one() {
    local src="$1"
    local dst="$2"

    # 如果已经是正确的软链，跳过
    if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
        echo "✅ $dst already linked"
        return
    fi

    # 如果目标存在且不是软链，备份
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "$dst.backup.$(date +%s)"
        echo "💾 Backup $dst"
    fi

    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    echo "🔗 Linked $dst → $src"
}

has() {
    command -v "$1" >/dev/null 2>&1
}

log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_warn() {
    echo -e "\033[0;33m[WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}
