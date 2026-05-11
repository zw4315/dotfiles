#!/usr/bin/env bash
# =============================================================================
# macOS 系统默认设置
# =============================================================================
# 运行后可能需要注销并重新登录才能完全生效。
# =============================================================================

log "Applying macOS system defaults..."

# 显示所有文件扩展名
macos_default NSGlobalDomain AppleShowAllExtensions bool true

# 显示状态栏和路径栏
macos_default com.apple.finder ShowStatusBar bool true
macos_default com.apple.finder ShowPathbar bool true

# 默认使用列表视图
macos_default com.apple.finder FXPreferredViewStyle string "Nlsv"

# 搜索时默认搜索当前文件夹
macos_default com.apple.finder FXDefaultSearchScope string "SCcf"

# 在 Finder 标题栏显示完整路径
macos_default com.apple.finder _FXShowPosixPathInTitle bool true

# 避免在网络卷上创建 .DS_Store
macos_default com.apple.desktopservices DSDontWriteNetworkStores bool true

# 避免在 USB 驱动器上创建 .DS_Store
macos_default com.apple.desktopservices DSDontWriteUSBStores bool true

# Dock 自动隐藏
macos_default com.apple.dock autohide bool true

# 截图复制到剪贴板（而不是保存到文件）
macos_default com.apple.screencapture target string "clipboard"

# 重启受影响的 App
kill_affected_apps

log_success "macOS defaults applied."
