#!/bin/bash
#
# bootstrap.sh
# Symbolically link dot files to the files in this directory,
# optionally backing up existing dot files.
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
  ln -s "$NEW" "$ORIG" && echo_l2 "...linked"
}

sync_dotfiles() {
  echo "Symlinking..."
  DOTFILES="$(find . -maxdepth 1 -name '.?*')" # ?* - Don't include ./.

  for DOTFILE in $DOTFILES; do
    [[ $DOTFILE != "./.git" ]] \
      && [[ $DOTFILE != "./.gitmodules" ]] \
      && [[ $DOTFILE != "./.gitignore" ]] \
      && [[ ! $DOTFILE =~ swp$ ]] \
      && link_file "$HOME/$DOTFILE" "$CHECKOUT_DIR/$DOTFILE"
  done
}

read -p "Backup files? (y/n) " -n 1; echo
BACKUP=$REPLY
cd "$(dirname "${BASH_SOURCE}")"
CHECKOUT_DIR="$PWD"
sync_dotfiles
