# AGENTS.md - Agent Coding Guidelines for dotfiles

## Overview

This is a dotfiles repository containing configuration files for development tools (bash, zsh, tmux, vim, neovim, git) and shell scripts for environment setup. It supports macOS (Darwin), Linux, and Windows.

The repository uses a **three-layer architecture**: Manifest → App → OS.

## Build/Test/Lint Commands

### Installation

```bash
# Dry run to see what would be linked
./init.sh --dry-run

# Apply default manifest for current OS
./init.sh

# With specific app
./init.sh --app git --dry-run
./init.sh --app git

# Single app only
./init.sh --app git --dry-run
./init.sh --app git
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
brew install shellcheck  # macOS
apt install shellcheck   # Ubuntu

# Lint shell scripts
shellcheck init.sh lib/*.sh apps/*/app.sh os/*/*.sh
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

## App System

Apps in `apps/<name>/app.sh` follow this pattern:

```bash
#!/usr/bin/env bash

APP_NAME="foo"
APP_DESC="Foo tool"
APP_DEPS=()

APP_BREW_FORMULA="foo"     # macOS package name (optional)
APP_APT_PACKAGE="foo"      # Linux package name (optional)
APP_WINGET_ID="Foo.Foo"    # Windows package ID (optional)

app_install() {
  pkg_install_auto "$APP_NAME"
}

app_configure() {
  link_home_file "$APP_DIR/config/foo.conf" ".foo.conf"
}

app_post_install() {
  log_info "  Foo is ready"
}
```

**Platform overrides**: Create `apps/<name>/darwin.sh` or `apps/<name>/linux.sh` to override functions for specific platforms. The override file is sourced after `app.sh`, so redefining a function replaces it.

### Manifest System

Manifests in `manifests/${DETECTED_OS}.toml` define the list of apps to install for each OS:

```toml
[core]
bash   = true
git    = true
zoxide = true

[editor]
nvim = true
tmux = true

[devtool]
ctags        = true
global       = true
clang-format = true
```

`init.sh` reads the manifest for the detected OS and installs only the apps marked `true`.

### Helper Functions (lib/common.sh)

Available from `lib/common.sh`:

- `log "message"` - print info message to stdout
- `log_success "message"` - print success message
- `log_warn "message"` - print warning to stderr
- `log_info "message"` - print dim info message
- `die "message"` - print error to stderr and exit 1
- `has_cmd "cmd"` - check if command exists
- `ensure_dir "/path"` - create directory if not exists
- `link_file "$src" "$dst"` - create symlink (with backup of existing files)
- `link_home_file "$src" "$name"` - link to `$HOME/$name`
- `link_config_dir "$src" "$name"` - link to `~/.config/$name`
- `pkg_install_auto "$app_name"` - install using OS-specific package manager

### Adding a New App

1. Create directory: `mkdir -p apps/<name>/config`
2. Create `apps/<name>/app.sh` with the standard template above
3. Declare platform-specific package names if needed (`APP_BREW_FORMULA`, `APP_APT_PACKAGE`)
4. Add `<name>` to `manifests/${OS}.toml` for target OS(s)
5. Test with `./init.sh --app <name> --dry-run`
6. Use `bash -n` to validate syntax: `bash -n apps/<name>/app.sh`

### Dotfile Linking Patterns

- Root-level dotfiles go in `home/` (e.g., `home/bashrc` → `~/.bashrc`)
- XDG config files go in `config/` (e.g., `config/nvim/` → `~/.config/nvim`)
- App-specific shared configs go in `apps/<name>/config/` (e.g., `apps/git/config/gitconfig`)
- Scripts go in `scripts/` (can be linked to `~/.local/bin/`)
- Shell env snippets go in `home/profile.d/` (sourced by `~/.profile` and `~/.zprofile`)

## Repository Structure

| Directory | Purpose |
|-----------|---------|
| `init.sh` | Main entry point for applying dotfiles |
| `lib/` | Shared helper functions (common.sh, darwin.sh, linux.sh, etc.) |
| `apps/` | Installable apps (bash, git, nvim, go, node, rust, etc.) |
| `manifests/` | OS-based app manifests (darwin.toml, linux.toml) + catalog.toml |
| `os/` | OS-specific bootstrap and defaults (darwin, linux) |
| `home/` | Dotfiles linked to `$HOME` (bashrc, zshrc, gitconfig, profile.d, etc.) |
| `config/` | XDG config directories (nvim, mihomo) |
| `scripts/` | Standalone helper scripts (proxy, yank, hfget) |
| `archive/` | Archived legacy code (old modules/) |

## macOS Notes

- Default shell is zsh, so `apps/bash/app.sh` links `.zshrc` and `.zprofile` on macOS
- Package manager is Homebrew (`lib/darwin.sh`)
- `apps/<name>/darwin.sh` can override any app behavior for macOS
- Run `os/darwin/defaults.sh` to apply system preferences

## Environment Variables

- `DOTFILES` - path to dotfiles repository (auto-detected from script location)
- `DRY_RUN` - set to 1 to preview changes without applying
