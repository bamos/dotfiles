set nocompatible

set shiftwidth=2 tabstop=2 expandtab
set wrap mouse=a
set dir=~/.vim/tmp backupdir=~/.vim/tmp
set ignorecase smartcase shiftround smartindent
set t_Co=256
set autochdir

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
runtime vundle.vim

set background=dark
try
  colorscheme lucius
catch /^Vim\%((\a\+)\)\=:E185/
  " Don't load a color scheme.
endtry
highlight Normal ctermbg=235 guibg=#262626
filetype plugin indent on

runtime macros.vim

" Fix Python indentation.
autocmd FileType python setlocal shiftwidth=2 tabstop=2

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

" Key mappings.
nmap <F4> :call ToggleSpell()<CR>
imap <F4> <Esc>:call ToggleSpell()<CR>
nmap <F6> :w<CR>:!make<CR>
nmap <F7> :source ~/.vim/pdf-replace.vim<CR>

" Commands.
" <leader>: \ (a backslash)
noremap <leader>W :w !sudo tee % > /dev/null<CR>
command Rm :call delete(expand('%')) | bdelete!

" Folding.
set foldmethod=manual
inoremap <F9> <C-O>za
nnoremap <F9> za
onoremap <F9> <C-C>za
vnoremap <F9> zf

" Use LaTeX rather than plain TeX.
let g:tex_flavor = "latex"

" Copy in the OSX terminal.
set clipboard=unnamed

set guioptions-=T  "remove menu bar

autocmd User GoyoEnter Limelight
autocmd User GoyoLeave Limelight!

" Save pointer location between sessions.
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Dvorak.
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
noremap k n
noremap K N
noremap h <left>
noremap t <down>
noremap n <up>
noremap s <right>

let g:go_version_warning = 0
let g:snipMate = { 'snippet_version' : 1 }
