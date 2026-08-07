#!/usr/bin/env bash

set -e

echo "🗑️  Uninstalling all Homebrew packages and Homebrew itself..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "ℹ️  Homebrew is not installed, nothing to uninstall"
    exit 0
fi

# Uninstall all packages from Brewfile
echo "📤 Uninstalling packages from Brewfile..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
    # Get list of installed formulae and casks from Brewfile
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        if [[ "$line" =~ ^brew[[:space:]]\"(.+)\" ]]; then
            package="${BASH_REMATCH[1]}"
            if brew list "$package" &> /dev/null; then
                echo "🗑️  Uninstalling formula: $package"
                brew uninstall --ignore-dependencies "$package" || true
            fi
        elif [[ "$line" =~ ^cask[[:space:]]\"(.+)\" ]]; then
            package="${BASH_REMATCH[1]}"
            if brew list --cask "$package" &> /dev/null; then
                echo "🗑️  Uninstalling cask: $package"
                brew uninstall --cask "$package" || true
            fi
        fi
    done < "$SCRIPT_DIR/Brewfile"
fi

# Uninstall Homebrew itself
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
