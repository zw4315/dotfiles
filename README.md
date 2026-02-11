# dotfiles

My minimal configuration for a development environment.

## Install

### Option A: New incremental installer (recommended)

This repo is migrating to an XDG-mirror layout (`config/`, later `home/` + `overlays/`). The new entrypoint is `init.sh`.

1. clone
```bash
mkdir -p ~/repo && cd ~/repo
git clone git@github.com:zw4315/dotfiles.git
cd dotfiles
```

2. dry-run (optional)
```bash
./init.sh --dry-run
```

3. apply
```bash
./init.sh
```

By default (Ubuntu profile), the MVP only links `config/nvim` to `~/.config/nvim`.

You can select a profile:
```bash
./init.sh
```

Profiles select modules (table-driven) by editing `profiles/*.sh`:
```bash
# e.g. profiles/ubuntu.sh
MODULES=(
  nvim=1
  legacy=0
)
```

### Option B: Legacy installer (kept for compatibility)

The legacy installer is `./setup` (Ubuntu-focused). You can still run it directly, or enable it in your profile with `legacy=1`.

## Directory layout (current)

- `config/nvim/`: Neovim config (XDG). Based on LazyVim starter. Linked to `~/.config/nvim` by `./init.sh`.
- `files/`: legacy dotfiles layout used by `./setup` (e.g. `files/vimrc`, `files/tmux.conf`).
- `profiles/`: per-OS config that selects modules to run (e.g. `profiles/ubuntu.sh`).
- `scripts/`: small helper scripts that can be linked to `~/bin` by the legacy installer.

## Notes

- Vim uses vim-plug: open Vim, run `:PlugInstall`.
- Neovim uses `lazy.nvim`: open `nvim`, run `:Lazy sync` (first run will bootstrap `lazy.nvim`).

## How to use

- hh 高亮 toggle
- hc 不改变高亮状态的情况下, 查询当前词是第几个
- hx remove all highlight
