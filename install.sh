#!/usr/bin/env bash
set -euo pipefail

# Just letting all the peeps know, I certainly did use Gippity to create this
# I just wanted to try out Stow and not get super hardcore into it. This should
# aid in that.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Packages to stow (add more as you create them)
PACKAGES=(
  shell
  vim
)

# Function to backup existing files
backup_existing_files() {
    local target_dir="$1"
    echo "Checking for existing dotfiles in $target_dir..."
    
    for package in "${PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/$package" ]; then
            # Find all files in the package directory
            find "$DOTFILES_DIR/$package" -type f -print0 | while IFS= read -r -d '' file; do
                # Get relative path from package directory
                rel_path="${file#$DOTFILES_DIR/$package/}"
                target_file="$target_dir/$rel_path"
                
                if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
                    echo "Found existing file: $target_file"
                    
                    # Create backup directory if it doesn't exist
                    if [ ! -d "$BACKUP_DIR" ]; then
                        mkdir -p "$BACKUP_DIR"
                        echo "Created backup directory: $BACKUP_DIR"
                    fi
                    
                    # Create subdirectories in backup if needed
                    backup_file="$BACKUP_DIR/${rel_path}"
                    backup_dir="$(dirname "$backup_file")"
                    mkdir -p "$backup_dir"
                    
                    # Move the existing file to backup
                    mv "$target_file" "$backup_file"
                    echo "Backed up $target_file to $backup_file"
                fi
            done
        fi
    done
}

echo "Stowing packages into $HOME ..."
cd "$DOTFILES_DIR"

# Backup existing files before stowing
backup_existing_files "$HOME"

# Stow the packages
stow -R "${PACKAGES[@]}"

# Optionally set up for root as well
if [ "$EUID" -ne 0 ]; then
  echo "To set up for root, run:"
  echo "    sudo $(realpath "$0")"
else
  echo "Stowing packages into /root ..."
  backup_existing_files "/root"
  stow -R -t /root "${PACKAGES[@]}"
fi

if [ -d "$BACKUP_DIR" ]; then
    echo "Backup created at: $BACKUP_DIR"
fi

echo "Done!"
