" mappings.vim

" Filetype mappings.
au BufRead,BufNewFile *.pyx set filetype=python
au BufRead,BufNewFile *.cl set filetype=cpp
au BufRead,BufNewFile *.thrift set filetype=thrift
au! BufRead,BufNewFile *.m,*.oct set filetype=octave
au! Syntax thrift source ~/.vim/syntax/thrift.vim

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

map <silent> , :call Comment(&ft)<CR>
nmap <F9> :source ~/.vim/pdf-replace.vim<CR>
nmap <F6> :w<CR>:!make<CR>
nmap <F4> :call ToggleSpell()<CR>
imap <F4> <Esc>:call ToggleSpell()<CR>

" Write a file using sudo.
noremap <leader>W :w !sudo tee % > /dev/null<CR>

" Toggle Caps Lock with 'Ctrl-^'
for c in range(char2nr('A'), char2nr('Z'))
  execute 'lnoremap ' . nr2char(c+32) . ' ' . nr2char(c)
  execute 'lnoremap ' . nr2char(c) . ' ' . nr2char(c+32)
endfor

" Delete files with ':Rm'.
command Rm :call delete(expand('%')) | bdelete!
