#!/usr/bin/env bash
# Linux (Debian/Ubuntu, x86_64) setup: installs tools and symlinks dotfiles.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

link() {
    mkdir -p "$(dirname "$2")"
    ln -sfn "$REPO/$1" "$2"
    echo "  $2 -> $REPO/$1"
}

echo "Installing apt packages..."
sudo apt-get update
sudo apt-get install -y git curl tar build-essential tmux python3 python3-venv \
    jq fd-find ripgrep fzf zoxide bash-completion

echo "Installing neovim to /opt/nvim..."
if [ ! -x /opt/nvim/bin/nvim ]; then
    sudo rm -rf /opt/nvim  # clear partial installs (overlayfs breaks hardlinks into existing dirs)
    curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
        | sudo tar -xz --one-top-level=/opt/nvim --strip-components=1
fi

echo "Installing lazygit..."
if ! command -v lazygit &>/dev/null; then
    ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r .tag_name | tr -d v)"
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_Linux_x86_64.tar.gz" \
        | sudo tar -xz -C /usr/local/bin lazygit
fi

echo "Installing uv (creates ~/.local/bin/env, sourced by .bashrc)..."
[ -f "$HOME/.local/bin/env" ] || curl -LsSf https://astral.sh/uv/install.sh | sh

echo "Installing nvm + node..."
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi
. "$NVM_DIR/nvm.sh"
nvm install --lts

echo "Linking dotfiles..."
link .bashrc "$HOME/.bashrc"
link .bash_aliases "$HOME/.bash_aliases"
link .gitconfig "$HOME/.gitconfig"
link .tmux.conf "$HOME/.tmux.conf"
link ghostty/config "$CONFIG/ghostty/config"
link lazygit/config.yml "$CONFIG/lazygit/config.yml"

echo "Done. Run: source ~/.bashrc"
