#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
MACOS_APP_SUPPORT="$HOME/Library/Application Support"

# First arg: path relative to this repo. Second arg: absolute symlink path.
link_pair() {
    local src="$REPO/$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$src" "$dest"
    printf '  %s -> %s\n' "$dest" "$src"
}

echo "Linking from $REPO"

link_pair ".zshrc" "$HOME/.zshrc"
link_pair ".bashrc" "$HOME/.bashrc"
link_pair ".bash_aliases" "$HOME/.bash_aliases"
link_pair ".gitconfig" "$HOME/.gitconfig"
link_pair ".tmux.conf" "$HOME/.tmux.conf"
link_pair ".aerospace.toml" "$HOME/.aerospace.toml"

link_pair "ghostty/config" "$CONFIG/ghostty/config"
link_pair "karabiner" "$CONFIG/karabiner"
link_pair "lazygit/config.yml" "$MACOS_APP_SUPPORT/lazygit/config.yml"
link_pair "linearmouse/linearmouse.json" "$MACOS_APP_SUPPORT/linearmouse/linearmouse.json"

echo "Done."
