#!/usr/bin/env bash
set -euo pipefail

# Just letting all the peeps know, I certainly did use Gippity to create this
# I just wanted to try out Stow and not get super hardcore into it. This should
# aid in that.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Packages to stow (add more as you create them)
PACKAGES=(
  shell
  vim
)

echo "🔗 Stowing packages into $HOME ..."
cd "$DOTFILES_DIR"
stow -R "${PACKAGES[@]}"

# Optionally set up for root as well
if [ "$EUID" -ne 0 ]; then
  echo "⚡ To set up for root, run:"
  echo "    sudo $(realpath "$0")"
else
  echo "🔗 Stowing packages into /root ..."
  stow -R -t /root "${PACKAGES[@]}"
fi

echo "✅ Done!"
