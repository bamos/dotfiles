set nocompatible

set shiftwidth=2 tabstop=2 expandtab
set number wrap mouse=a
set dir=~/.vim/tmp backupdir=~/.vim/tmp

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
let g:pymode_lint = 0
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" Don't remap '#' to avoid smartindent problem
:inoremap # X<BS>#

" Spelling.
function! ToggleSpell()
  if !exists("b:spell")
    setlocal spell spelllang=en_us
    let b:spell = 1
  else
    setlocal nospell
    unlet b:spell
  endif
endfunction

nmap <F4> :call ToggleSpell()<CR>
imap <F4> <Esc>:call ToggleSpell()<CR>
nnoremap <F5> :GundoToggle<CR>
nmap <F6> :w<CR>:!make<CR>
nmap <F7> :source ~/.vim/pdf-replace.vim<CR>

" Write a file using sudo.
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Delete files with ':Rm'.
command Rm :call delete(expand('%')) | bdelete!
