# AGENTS.md - Agent Coding Guidelines for dotfiles

## Overview

This is a dotfiles repository containing configuration files for development tools (bash, tmux, vim, neovim, git) and shell scripts for environment setup. The repository uses an XDG-mirror layout with modular installation.

## Build/Test/Lint Commands

### Installation

```bash
# Dry run to see what would be linked
./init.sh --dry-run

# Apply configurations (default: ubuntu profile)
./init.sh

# With specific profile
DOTFILES_PROFILE=ubuntu ./init.sh
```

### Testing Changes

This is a dotfiles repository with no formal test suite. Test changes by:

1. Run with `--dry-run` to preview changes
2. Manually verify linked files work correctly
3. For neovim: open nvim and run `:checkhealth` or `:Lazy sync`

### Linting

Shell scripts should pass [shellcheck](https://www.shellcheck.net/):

```bash
# Install shellcheck if needed
apt install shellcheck  # Ubuntu

# Lint a shell script
shellcheck scripts/proxy
shellcheck modules/nvim.sh
shellcheck lib/common.sh
```

For Lua (neovim config), use [stylua](https://github.com/astral-sh/stylua) for formatting:

```bash
# Format lua files
stylua config/nvim/lua/
```

## Code Style Guidelines

### Shell Scripts (bash)

- Shebang: `#!/usr/bin/env bash` with strict mode: `set -euo pipefail`
- Functions/variables: `snake_case`, constants: `UPPER_SNAKE_CASE`
- Scripts in `scripts/`: executable, no extension
- Define functions before use; use local variables: `local var="$1"`
- Return values via `printf '%s' "$value"`, use return codes (0=success)
- Error handling: use `die()` helper; check exit codes with `cmd || die`
- Variables: always quote `"$var"`, use `${var:-default}` for defaults
- Conditionals: use `[[ ]]` not `[ ]`, use `==` for strings, `-eq` for numbers
- Arrays: declare with `local -a arr=(...)`, iterate with `for item in "${arr[@]}"`
- Shellcheck: use `shellcheck source=/dev/null` when sourcing external files

### Neovim Configuration (Lua)

Based on LazyVim. See `config/nvim/stylua.toml` for formatting rules.

- Follow LazyVim conventions (see LazyVim documentation)
- Use `require("plugins")....` pattern for plugin config
- Use `opts = {}` for plugin options
- File structure: `init.lua` - entry point, `lua/plugins/` - plugin specs, `lua/config/` - user config

### Module System

Modules in `modules/*.sh` follow this pattern:

```bash
#!/usr/bin/env bash

module_main() {
  local value="${1:-1}"
  is_enabled "$value" || { log "⏭️  module disabled"; return 0; }
  
  # module logic here
}

# Allow running module directly for testing
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail
  DOTFILES="${DOTFILES:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
  # shellcheck source=/dev/null
  source "$DOTFILES/lib/common.sh"
  module_main "${1:-1}"
fi
```

### Profile System

Profiles in `profiles/*.sh` define enabled modules:
```bash
dotfiles_profile_apply() {
  cat <<'EOF'
nvim=1
tmux=1
git=1
EOF
}
```

### Helper Functions (lib/common.sh)

Available from `lib/common.sh`:

- `log "message"` - print info message to stdout
- `die "message"` - print error to stderr and exit 1
- `is_enabled "value"` - returns 0 if enabled (1, on, true, yes)
- `ensure_dir "/path"` - create directory if not exists
- `link_one "$src" "$dst"` - create symlink (with backup of existing files)

### Adding New Modules

1. Create `modules/<name>.sh` with `module_main` function
2. Add to profile in `profiles/ubuntu.sh` as `<name>=1`
3. Test with `./init.sh --dry-run`
4. Use shellcheck to validate: `shellcheck modules/<name>.sh`

### Dotfile Linking Patterns

- Root-level dotfiles go in `home/` (e.g., `home/bashrc` → `~/.bashrc`)
- XDG config files go in `config/` (e.g., `config/nvim/` → `~/.config/nvim`)
- Scripts go in `scripts/` (can be linked to `~/.local/bin/`)

## Repository Structure

| Directory | Purpose |
|-----------|---------|
| `init.sh` | Main entry point for applying dotfiles |
| `lib/` | Shared helper functions (common.sh, appimage.sh, etc.) |
| `modules/` | Installable modules (nvim.sh, tmux.sh, git.sh, etc.) |
| `profiles/` | OS-specific module selections (ubuntu.sh, windows.sh) |
| `home/` | Dotfiles linked to `$HOME` (bashrc, gitconfig, etc.) |
| `config/` | XDG config directories (nvim, mihomo) |
| `scripts/` | Standalone helper scripts (proxy, yank, hfget) |

## Environment Variables

- `DOTFILES` - path to dotfiles repository (auto-detected from script location)
- `DOTFILES_PROFILE` - profile to use (ubuntu, windows)
- `DRY_RUN` - set to 1 to preview changes without applying
