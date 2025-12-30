#!/bin/bash

# Module: tools
# Handles custom tools installation (yank, zoxide)

install_yank() {
    local dst="$DOTFILES/scripts/yank"
    local url="https://raw.githubusercontent.com/sunaku/home/master/bin/yank"

    if [[ -f "$dst" ]]; then
        log_success "yank already exists."
    else
        log_info "Downloading yank..."
        mkdir -p "$(dirname "$dst")"
        if has curl; then
            curl -fsSL "$url" -o "$dst"
        elif has wget; then
            wget -qO "$dst" "$url"
        else
            log_error "Need curl or wget to download yank"
            return 1
        fi
        chmod +x "$dst"
    fi
}

install_zoxide() {
    if has zoxide; then
        log_success "zoxide already installed."
        return
    fi

    log_info "Installing zoxide..."
    # Try apt first, then fallback to script
    if has apt-get; then
        sudo apt-get install -y zoxide || \
            curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    else
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
}

run_module() {
    install_yank
    install_zoxide
}
