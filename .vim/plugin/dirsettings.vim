"
" Plugin: dirsettings
"
" Version: 1.0
"
" Description:
"
"   This is a very simple plugin that allows for directory tree-specific vim
"   settings.  For every file edited, it searches upward from that file's
"   directory for a file named '.vimdir' and sources it.
"
" Maintainer: Tye Z. < z d r o @ y a h o o . c o m >
"
" 

if version < 700
    finish
endif

" Define a group so we can delete them when this file is sourced, and we don't
" end up with multiple autocmd entries if this file is sourced more than once.
augroup dirsettings
au! dirsettings
au dirsettings BufNewFile,BufReadPost * call SourceFileUpward('.vimdir')

"
" Search upward for the given file and source it.  This makes for a simpler
" autocmd line.
"
func! SourceFileUpward(fname)
    let s=FindFileUpward(a:fname)
    if filereadable(s)
        exe 'sou ' . s
    endif
endfunc

"
" Search upward for the given file.
"
func! FindFileUpward(fname)
    let s=findfile(a:fname, expand("%:p:h") . ';')
    return s
endfunc
