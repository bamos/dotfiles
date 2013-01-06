#!/bin/bash

echo "Updating..."
cd "$(dirname "${BASH_SOURCE}")"
git pull

function sync_dotfiles() {
    rsync --exclude ".git/" --exclude "bootstrap.sh" \
        --exclude "README.md" -av . ~
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    sync_dotfiles
else
    read -p "This may overwrite existing files in "`
      `"your home directory. Are you sure? (y/n) " -n 1
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sync_dotfiles
    fi
fi
unset sync_dotfiles
