# dotfiles

Minimal personal development environment configuration.

## Quick Start

```bash
mkdir -p ~/repo && cd ~/repo
git clone git@github.com:zw4315/dotfiles.git
cd dotfiles
./init.sh --dry-run
./init.sh
```

## Structure

- `home/`: root dotfiles linked into `$HOME`
- `config/`: XDG config linked into `$HOME/.config`
- `modules/`: install/link modules used by `init.sh`
- `profiles/`: profile presets for module selection
- `scripts/`: helper scripts linked to `~/.local/bin`

## Documentation

- `docs/README.md`: docs index and update rules
- `docs/SETUP.md`: install, upgrade, and troubleshooting
- `docs/NVIM.md`: Neovim keymap + workflow (single source)
- `docs/ROADMAP.md`: medium-term direction
- `docs/BACKLOG.md`: prioritized task list
- `docs/notes.md`: personal notes (free-form)
