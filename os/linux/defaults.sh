#!/usr/bin/env bash
# =============================================================================
# Linux 系统默认设置
# =============================================================================
# Linux 特定的系统级配置。
# 由于 Linux 发行版差异大，这里主要做用户级配置。
# =============================================================================

log "Applying Linux system defaults..."

# 可以在这里添加 GNOME/KDE 等桌面环境的设置
# 例如：
# gsettings set org.gnome.desktop.interface show-battery-percentage true

log_success "Linux defaults applied."
