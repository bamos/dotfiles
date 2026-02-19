#!/bin/bash
#
# bootstrap.sh
# Symlink all dotfiles in this repo to $HOME.
#
# Brandon Amos
# 2013.01.20

set -e

link_file() {
  local ORIG="$1"; local NEW="$2"

  echo "  '$ORIG'"
  if [[ $BACKUP =~ ^[Yy]$ ]]; then
    mv "$ORIG" "${ORIG}.prebamos" &> /dev/null \
    && echo "    ...backed up"
  else
    rm -rf "$ORIG"
    echo "    ...deleted"
  fi
  ln -s "$NEW" "$ORIG" && echo "    ...linked"
}

if [[ $# == 1 ]]; then
  [[ $1 =~ '-y' ]] && BACKUP='y'
  [[ $1 =~ '-n' ]] && BACKUP='n'
else
  read -p "Backup files? (y/n) " -n 1; echo
  BACKUP=$REPLY
fi

cd "$(dirname "${BASH_SOURCE}")"

echo "Updating submodules..."
git submodule sync --recursive
git submodule update --init --recursive

if [[ -d ".fzf" ]]; then
  if [[ ! -x ".fzf/bin/fzf" ]]; then
    echo "Installing fzf..."
    (cd .fzf && ./install --bin --no-update-rc)
  fi
fi

echo "Symlinking..."

for DOTFILE in $(find . -maxdepth 1 -name '.?*'); do
  [[ $DOTFILE != "./.git" ]] \
    && [[ $DOTFILE != "./.gitmodules" ]] \
    && [[ $DOTFILE != "./.gitignore" ]] \
    && [[ $DOTFILE != "./.config" ]] \
    && [[ $DOTFILE != "./screenshots" ]] \
    && [[ ! $DOTFILE =~ swp$ ]] \
    && link_file "$HOME/$DOTFILE" "$PWD/$DOTFILE"
done

mkdir -p $HOME/.config
cd .config
for DOTFILE in $(find . -maxdepth 1 ! -path .); do
  link_file "$HOME/.config/$DOTFILE" "$PWD/$DOTFILE"
done

vim +BundleInstall +qall

if $(uname -s | grep -q "Darwin"); then
    rm -rf "$HOME/Library/Application Support/xbar/plugins"
    mkdir -p "$HOME/Library/Application Support/xbar"
    ln -s "$PWD/.xbar" "$HOME/Library/Application Support/xbar/plugins"
fi
