set nocompatible
syntax on
set smartindent
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab
set number

set ruler
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
set showcmd

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
