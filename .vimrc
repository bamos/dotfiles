set nocompatible
syntax on
set smartindent
set shiftwidth=4
set tabstop=4
set expandtab
set smarttab

if has("gui_running")
    colorscheme desert
endif

set laststatus=2
set statusline=
set statusline+=%-3.3n\
set statusline+=%f\
set statusline+=%h%m%r%w
set statusline+=\[%{strlen(&ft)?&ft:'none'}]
set statusline+=%=
set statusline+=0x%-8b
set statusline+=%-14(%l,%c%v%)
set statusline+=%<%p


" Spell check
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

" Don't remap '#' to avoid smartindent problem
:inoremap # X<BS>#
