# Setup Guide

## Install

```bash
mkdir -p ~/repo && cd ~/repo
git clone git@github.com:zw4315/dotfiles.git
cd dotfiles
./init.sh --dry-run
./init.sh
```

## Common Commands

- Re-apply links/config: `./init.sh`
- Preview changes only: `./init.sh --dry-run`
- Neovim plugin sync: `nvim "+Lazy sync" +qa`

## Verification

- Check shell links: `ls -l ~/.bashrc ~/.profile ~/.gitconfig`
- Check Neovim config link: `ls -l ~/.config/nvim`
- Check tools: `git --version`, `rg --version`, `fd --version`

## Troubleshooting

- `return: can only 'return' from a function or sourced script`
  - Usually means a shell rc file is being executed as a script.
  - Use `source ~/.bashrc` or open a new shell instead of running `.bashrc` directly.
- Neovim keymap mismatch
  - Run `:verbose nmap <key>` to see the effective source.
  - Use `docs/NVIM.md` as the canonical keymap reference.
- Plugins not updated
  - Run `:Lazy sync` and restart Neovim.
