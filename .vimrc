set nocompatible
syntax on
set autoindent
set smartindent
filetype plugin indent on
set shiftwidth=2
set tabstop=2
"autocmd FileType python setlocal shiftwidth=2 tabstop=2
set expandtab
set smarttab
set number " Show line numbers.
set nowrap " Don't wrap text.
set mouse=a " Use mouse in all modes.
set modeline
"set textwidth=75
"filetype off
colorscheme hemisu
set background=dark

call pathogen#infect()
let g:syntastic_check_on_open=1

filetype plugin indent on

set ruler
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
set showcmd

set printoptions=number:y,paper:letter
set printheader=%<%f%h%m%=Page\ %N\ of\ %{line('$')/69+1}

set dir=~/.vim/tmp
set backupdir=~/.vim/tmp

set laststatus=2
set statusline=%<%f\
set statusline+=%w%h%m%r
set statusline+=\ [%{&ff}/%Y]
set statusline+=\ [%{getcwd()}]
set statusline+=%=%-14.(%l,%c%V%)\ %p%%

function! ToggleLineLength()
    if !exists("b:line")
        match ErrorMsg '\%>75v.\+'
        let b:line = 1
    else
        match none
        unlet b:line
    endif
endfunction

function! ToggleSpell()
    if !exists("b:spell")
        setlocal spell spelllang=en_us
        let b:spell = 1
    else
        setlocal nospell
        unlet b:spell
    endif
endfunction
" call ToggleSpell()
 
nmap <F4> :call ToggleSpell()<CR>
imap <F4> <Esc>:call ToggleSpell()<CR>
nmap <F3> :call ToggleLineLength()<CR>
imap <F3> <Esc>:call ToggleLineLength()<CR>

" Don't remap '#' to avoid smartindent problem
:inoremap # X<BS>#

let g:localvimrc_sandbox=0
let g:localvimrc_ask=0

let @c = '€khi%~ €kd€kh'

" Comments
map <silent> , :call Co(&ft)<CR>

:ab mkeline =========================================================================
:ab mkdline -------------------------------------------------------------------------

noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
          \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), l:modeline)
endfunction
noremap <silent> <Leader>ml :call AppendModeline()<CR>

let g:clang_user_options='|| exit 0'
let g:clang_auto_select=1 " Automatically select the first option.
let g:clang_close_preview=1 " Close the preview window after a selection.

" Macros.
let @i = 'i\begin{itemize}\item\end{itemize}€kua '
let @p = 'wdwiDr. OBOB'
let @f = '2wDxa,OBOB'
let @r = 'iRegards,Brandon.'

" Toggle Caps Lock with 'Ctrl-^'
for c in range(char2nr('A'), char2nr('Z'))
  execute 'lnoremap ' . nr2char(c+32) . ' ' . nr2char(c)
  execute 'lnoremap ' . nr2char(c) . ' ' . nr2char(c+32)
endfor

nmap <F6> :w<CR>:!make<CR>

au BufRead,BufNewFile *.thrift set filetype=thrift
au! Syntax thrift source ~/.vim/syntax/thrift.vim
