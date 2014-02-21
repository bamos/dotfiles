syntax on

set autoindent smartindent shiftwidth=2 tabstop=2 expandtab smarttab
set number wrap mouse=a modeline
set ruler rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) showcmd
set dir=~/.vim/tmp backupdir=~/.vim/tmp

filetype plugin indent on

set background=dark
colorscheme hemisu

" Filetype mappings.
au BufRead,BufNewFile *.pyx set filetype=python
au BufRead,BufNewFile *.cl set filetype=cpp
au BufRead,BufNewFile *.thrift set filetype=thrift
au! BufRead,BufNewFile *.m,*.oct set filetype=octave 
au! Syntax thrift source ~/.vim/syntax/thrift.vim

" Status line.
set laststatus=2
set statusline=%<%f\
set statusline+=%w%h%m%r
set statusline+=\ [%{&ff}/%Y]
set statusline+=\ [%{getcwd()}]
set statusline+=%=%-14.(%l,%c%V%)\ %p%%

" Don't remap '#' to avoid smartindent problem
:inoremap # X<BS>#

" Fix Python indentation.
autocmd FileType python setlocal shiftwidth=2 tabstop=2

" Custom key mappings.
map <silent> , :call Comment(&ft)<CR>
nmap <F9> :source ~/.vim/pdf-replace.vim
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

" Custom commands.
command Rm :call delete(expand('%')) | bdelete!

" LaTeX macros.
let @i = 'i\begin{itemize}\item\end{itemize}€kua '

" Mutt macros.
" 'p' and 'f' operate on a phrase of the format 'Hi First Last,'.
let @p = 'wdwiDr. OBOB' " Hi Dr. Last,
let @f = '2wDxa,OBOB' " Hi First,
let @r = 'iRegards,Brandon.'
