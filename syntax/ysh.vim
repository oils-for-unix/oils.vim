" Vim syntax definition for YSH

if exists("b:current_syntax")
  finish
endif

" :call SynStack()
" Debug function that displays the stack of lexer modes under the cursor
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" This avoids problems with long multiline strings
:syntax sync minlines=200

" Only ONE of these should be active

"source <sfile>:h/debug.vim
"source <sfile>:h/stage1-minimal.vim
source <sfile>:h/stage2-recursive-modes.vim

let b:current_syntax = "ysh"
