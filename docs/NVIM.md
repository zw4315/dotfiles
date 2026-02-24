# Neovim Guide

Single source for Neovim keymap and daily workflows in this repo.

## Conventions

- `<leader>g*`: Git operations (Diffview + LazyVim git pickers)
- `<leader>t*`: gtags navigation
- `<leader>o*`: notes (telekasten)
- `<leader>b*`: bookmarks
- `<leader>u*`: UI toggles

## Quick Keymap

### gtags

| Key | Action |
|---|---|
| `<leader>td` | gtags definition |
| `<leader>tr` | gtags references |
| `<leader>ts` | gtags symbol |
| `<leader>tf` | gtags current file |

### Git / Diffview

| Key | Action |
|---|---|
| `<leader>gg` | open Diffview |
| `<leader>gq` | close Diffview |
| `<leader>gh` | current file history |
| `<leader>gH` | repository history |
| `<leader>gc` | compare range (input commit range) |
| `<leader>gd` | git diff hunks picker |
| `<leader>gs` | git status picker |

### Explorer / Terminal

| Key | Action |
|---|---|
| `<leader>e` / `<leader>E` | Snacks explorer (root/cwd) |
| `<leader>ft` | Snacks floating terminal (root) |
| `<C-/>` | Snacks bottom terminal (root toggle) |

### Search / Highlight

| Key | Action |
|---|---|
| `n` / `N` | next/prev match with hlslens |
| `<leader>k` | highlight current word / selection |
| `<leader>K` | clear multi-word highlights |
| `<leader>l` | clear search highlight (`:noh`) |

### Notes / Bookmarks

| Key | Action |
|---|---|
| `<leader>op` / `od` / `ow` / `on` | telekasten panel/today/week/new |
| `<leader>ol` / `oc` / `of` / `os` | link/calendar/find/search |
| `<leader>ba` / `bg` / `bl` | bookmark add/jump/list |
| `<leader>bn` / `bp` | next/prev bookmark |
| `<leader>bc` / `bi` | bookmark command/info |

## Workflows

### Read Code Fast

1. Use `<leader>td` to jump with gtags.
2. Use `<leader>tr` / `<leader>ts` to expand call paths.
3. Use LSP `gd` / `gr` when semantic accuracy is needed.
4. Use `<F8>` or `<leader>co` for structure view.

### Review Git Changes

1. Open `<leader>gg`.
2. Focus/toggle file panel with `<leader>e` / `<leader>b` (inside Diffview).
3. Stage/unstage with `s` or `-` in file panel.
4. Use `S` / `U` for stage-all/unstage-all.
5. Use `<leader>gc` for `A..B` or `main...HEAD` comparisons.

### Terminal Usage

- `exit` or `Ctrl-d`: exit shell process.
- `<C-/>`: hide/show terminal window.
- `<leader>ft` and `<C-/>` may target the same terminal instance if already created.

## gtags Auto Update

Configured in `config/nvim/lua/plugins/gtags.lua`:

- `BufReadPost`: generate database if missing
- `BufWritePost`: incremental update
- `VimLeavePre`: full update fallback

## Notes

- This file is the only maintained keymap reference.
- LazyVim defaults are not exhaustively duplicated here.
