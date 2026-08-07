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

# Clean up PATH modifications from shell profile
if [[ $(uname -m) == "arm64" ]]; then
    echo "🧹 Cleaning up PATH modifications..."
    if [[ -f ~/.zprofile ]]; then
        sed -i '' '/eval.*\/opt\/homebrew\/bin\/brew shellenv/d' ~/.zprofile
    fi
fi

echo "✅ Homebrew and all packages have been uninstalled!"
