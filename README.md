# Installation

This repo uses git submodules. The simplest setup is:

```sh
git clone --recursive https://github.com/bamos/dotfiles.git
cd dotfiles
./bootstrap.sh
```

If you already cloned without submodules (or switched protocols), run:

```sh
git submodule sync --recursive
git submodule update --init --recursive
```

`bootstrap.sh` creates the symlinks in your home directory and bootstraps
additional programs.
