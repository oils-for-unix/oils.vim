" Vim syntax definition for YSH

if exists("b:current_syntax")
  finish
endif

" This avoids problems with long multiline strings
:syntax sync minlines=200

" Vim has special $ENV_VAR syntax
" s: is a 'script local' variable
if exists('$YSH_SYNTAX_STAGE')
  let s:stage = str2nr($YSH_SYNTAX_STAGE)
else
  let s:stage = 3
endif

if s:stage == 1
  source <sfile>:h/stage1-minimal.vim
elseif s:stage == 2
  source <sfile>:h/stage2-recursive-modes.vim
elseif s:stage == 3
  source <sfile>:h/stage3-details.vim
else
  echoerr 'Invalid stage ' . s:stage
endif

"source <sfile>:h/debug.vim

let b:current_syntax = "ysh"
