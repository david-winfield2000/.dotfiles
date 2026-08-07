#!/usr/bin/env bash

set -e

echo "🗑️  Uninstalling Homebrew casks and Homebrew itself..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "ℹ️  Homebrew is not installed, nothing to uninstall"
    exit 0
fi

# Uninstall casks from Brewfile (formulae will be removed automatically with Homebrew)
echo "📤 Uninstalling casks from Brewfile..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Only uninstall casks (formulae will be removed with Homebrew)
        if [[ "$line" =~ ^cask[[:space:]]\"(.+)\" ]]; then
            package="${BASH_REMATCH[1]}"
            if brew list --cask "$package" &> /dev/null; then
                echo "🗑️  Uninstalling cask: $package"
                brew uninstall --cask "$package" || true
            fi
        fi
    done < "$SCRIPT_DIR/Brewfile"
fi

# Uninstall Homebrew itself (this removes all formulae automatically)
echo "🗑️  Uninstalling Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"

# Clean up leftover Homebrew files and directories with sudo
echo "🧹 Cleaning up leftover Homebrew files..."
if [[ -d /opt/homebrew ]]; then
    echo "  Removing leftover files in /opt/homebrew..."
    sudo rm -rf /opt/homebrew/* 2>/dev/null || true
    sudo rmdir /opt/homebrew 2>/dev/null || true
fi

# Remove /etc/paths.d/homebrew if it exists
if [[ -f /etc/paths.d/homebrew ]]; then
    echo "  Removing /etc/paths.d/homebrew..."
    sudo rm -f /etc/paths.d/homebrew 2>/dev/null || true
fi

# Clean up PATH modifications from shell profile
if [[ $(uname -m) == "arm64" ]]; then
    echo "🧹 Cleaning up PATH modifications from shell profile..."
    if [[ -f ~/.zprofile ]]; then
        sed -i '' '/eval.*\/opt\/homebrew\/bin\/brew shellenv/d' ~/.zprofile
    fi
fi

echo "✅ Homebrew and all packages have been uninstalled!"
