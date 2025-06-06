if exists("b:current_syntax")
  finish
endif

" why doesn't \< work?
" syn match varSplice '\<@[a-zA-Z_][a-zA-Z0-9_]*'
syn match varSplice '@[a-zA-Z_][a-zA-Z0-9_]*'

hi def link varSplice Identifier

let b:current_syntax = "ysh"
