#!/bin/bash

# Module: links
# Handles symlinking files and scripts

link_vim_preserve_plugins() {
    local src_root="$1"
    local dst_root="$2"

    mkdir -p "$dst_root"

    for sub in "$src_root"/*; do
        local base
        base="$(basename "$sub")"
        link_one "$sub" "$dst_root/$base"
    done
}

run_module() {
    log_info "Linking dotfiles..."
    
    # Link files to $HOME/.*
    for path in "$DOTFILES/files"/*; do
        local name
        name="$(basename "$path")"

        if [[ "$name" == "vim" ]]; then
            link_vim_preserve_plugins "$path" "$HOME/.vim"
        elif [[ "$name" == "global" ]]; then
             # global/gtags.conf -> ~/.globalrc or similar? 
             # Original setup linked it to ~/.global
             link_one "$path" "$HOME/.$name"
        else
            link_one "$path" "$HOME/.$name"
        fi
    done

    log_info "Linking scripts..."
    local scripts_dir="$DOTFILES/scripts"
    local bin_dir="$HOME/bin"

    if [[ -d "$scripts_dir" ]]; then
        mkdir -p "$bin_dir"
        for path in "$scripts_dir/"*; do
            [[ -f "$path" ]] || continue
            local name
            name=$(basename "$path")
            link_one "$path" "$bin_dir/$name"
            chmod +x "$path"
        done
        
        if ! echo "$PATH" | grep -q "$HOME/bin"; then
            log_warn "Please add $HOME/bin to your PATH: export PATH=\"\$HOME/bin:\$PATH\""
        fi
    fi
}
