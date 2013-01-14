#!/bin/bash

function echo_l1 { echo "    $@"; }
function echo_l2 { echo_l1 "    $@"; }

function link_file() {
    local ORIG="$1"
    local NEW="$2"

    echo_l1 "'$ORIG'"
    if [[ $BACKUP =~ ^[Yy]$ ]]; then
        mv "$ORIG" "${ORIG}.prebamos" &> /dev/null \
        && echo_l2 "...backed up"
    else
        rm -rf "$ORIG"
        echo_l2 "...deleted"
    fi
    ln -s "$NEW" "$ORIG" \
        && echo_l2 "...linked"
}

function sync_dotfiles() {
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

#########
# Start #
#########

read -p "Backup files? (y/n) " -n 1; echo
BACKUP=$REPLY
cd "$(dirname "${BASH_SOURCE}")"
CHECKOUT_DIR="$PWD"
sync_dotfiles
