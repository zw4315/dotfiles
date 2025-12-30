#!/bin/bash

# Module: apt
# Handles Debian/Ubuntu package installation

run_module() {
    log_info "Checking system packages..."
    
    local pkgs=()
    add_pkg() { has "$1" || pkgs+=("${2:-$1}"); }

    add_pkg fzf
    add_pkg clang-format
    add_pkg rg ripgrep
    add_pkg ctags universal-ctags
    add_pkg global global
    add_pkg cscope
    add_pkg pygmentize python3-pygments
    add_pkg pipx

    if ((${#pkgs[@]})); then
        log_info "Installing missing packages: ${pkgs[*]}"
        sudo apt-get update
        sudo apt-get install -y "${pkgs[@]}"
    else
        log_success "All system packages are already installed."
    fi
}
