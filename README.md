# dotfiles

My minimal configuration for a development environment.

## Install

### Option A: New incremental installer (recommended)

This repo is migrating to an XDG-mirror layout (`config/`) plus `home/` (root-level dotfiles). The new entrypoint is `init.sh`.

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
dotfiles_profile_apply() {
  cat <<'EOF'
nvim=1
tmux=1
EOF
}
```

## Directory layout (current)

- `config/nvim/`: Neovim config (XDG). Based on LazyVim starter. Linked to `~/.config/nvim` by `./init.sh`.
- `home/`: root-level dotfiles (e.g. `home/bashrc` -> `~/.bashrc`, `home/profile` -> `~/.profile`, `home/gitconfig` -> `~/.gitconfig`).
- `profiles/`: per-OS config that selects modules to run (e.g. `profiles/ubuntu.sh`).
- `scripts/`: small helper scripts that can be linked to `~/.local/bin` by the `scripts` module.

## Notes

- Vim uses vim-plug: open Vim, run `:PlugInstall`.
- Neovim uses `lazy.nvim`: open `nvim`, run `:Lazy sync` (first run will bootstrap `lazy.nvim`).

## How to use

- hh 高亮 toggle
- hc 不改变高亮状态的情况下, 查询当前词是第几个
- hx remove all highlight
