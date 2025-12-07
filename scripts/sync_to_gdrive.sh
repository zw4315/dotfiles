#!/bin/bash

SRC="$HOME/gdshare"
DEST="gdrive:gdshare"
BACKUP="gdrive:gdshare_backup/$(date +%Y-%m-%d)"

echo "📤 Syncing $SRC -> $DEST ..."
rclone sync -L "$SRC" "$DEST" \
  --backup-dir "$BACKUP" \
  --suffix ".$(date +%Y-%m-%d_%H-%M-%S).bak" \
  --exclude ".git/**" --exclude "*.tmp" \
  -P --stats=10s --stats-one-line
echo "✅ Sync done. Backup dir: $BACKUP"

