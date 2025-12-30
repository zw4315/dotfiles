#!/bin/bash

# Dotfiles configuration
# Define which modules to enable

# Default modules for Linux/Debian
MODULES=(
    links
    apt
    tools
)

# Platform specific overrides
case "$(uname -s)" in
    Linux*)
        # Keep default or add linux specific modules
        ;;
    Darwin*)
        # For macOS, maybe replace 'apt' with 'brew'
        MODULES=(links tools)
        ;;
    *)
        log_warn "Unknown platform: $(uname -s). Using default links module."
        MODULES=(links)
        ;;
esac
