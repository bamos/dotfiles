set nocompatible
syntax on

set autoindent smartindent shiftwidth=2 tabstop=2 expandtab smarttab
set number wrap mouse=a modeline
set dir=~/.vim/tmp backupdir=~/.vim/tmp
set laststatus=2 " vim-airline.

" Vundle.
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
runtime vundle.vim

" Skins.
set background=dark
colorscheme jellybeans

filetype plugin indent on

runtime mappings.vim
runtime macros.vim

" Fix Python indentation.
autocmd FileType python setlocal shiftwidth=2 tabstop=2
