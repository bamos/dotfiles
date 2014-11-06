#!/bin/bash
#
# bootstrap.sh
# Symlink all dotfiles in this repo to $HOME.
#
# Brandon Amos
# 2013.01.20

link_file() {
  local ORIG="$1"; local NEW="$2"

  echo "  '$ORIG'"
  if [[ $BACKUP =~ ^[Yy]$ ]]; then
    mv "$ORIG" "${ORIG}.prebamos" &> /dev/null \
    && echo "    ...backed up"
  else
    rm -f "$ORIG"
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
CHECKOUT_DIR="$PWD"

echo "Symlinking..."
DOTFILES="$(find . -maxdepth 1 -name '.?*')" # ?* - Don't include ./.

for DOTFILE in $DOTFILES; do
  [[ $DOTFILE != "./.git" ]] \
    && [[ $DOTFILE != "./.gitmodules" ]] \
    && [[ $DOTFILE != "./.gitignore" ]] \
    && [[ $DOTFILE != "./screenshots" ]] \
    && [[ ! $DOTFILE =~ swp$ ]] \
    && link_file "$HOME/$DOTFILE" "$CHECKOUT_DIR/$DOTFILE"
done

vim +BundleInstall +qall
