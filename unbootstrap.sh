#!/usr/bin/env bash
set -euo pipefail

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
MACOS_APP_SUPPORT="$HOME/Library/Application Support"

# Removes a path only if it is a symlink (won't delete a regular file).
# Keep this list in sync with bootstrap.sh — comment out the same entries per machine.
remove_symlink() {
  local dest="$1"
  if [[ -L "$dest" ]]; then
    rm "$dest"
    printf '  removed %s\n' "$dest"
  elif [[ -e "$dest" ]]; then
    printf '  skip (not a symlink): %s\n' "$dest" >&2
  else
    printf '  skip (missing): %s\n' "$dest"
  fi
}

echo "Removing symlinks created by bootstrap (same paths as unbootstrap list)"

remove_symlink "$HOME/.zshrc"
remove_symlink "$HOME/.bashrc"
remove_symlink "$HOME/.bash_aliases"
remove_symlink "$HOME/.gitconfig"
remove_symlink "$HOME/.tmux.conf"
remove_symlink "$HOME/.aerospace.toml"

remove_symlink "$CONFIG/ghostty/config"
remove_symlink "$CONFIG/karabiner"
remove_symlink "$MACOS_APP_SUPPORT/lazygit/config.yml"

echo "Done."
