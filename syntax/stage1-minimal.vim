" Vim syntax definition for YSH
" This is stage 1 - Lex Comments and String Literals.  See checklist.md.

" You can quote the special characters for comments and string literals
syn match backslashQuoted /\\[#'"\\]/
hi def link backslashQuoted Character

" Empty cluster.  In stage 1, it's ignored.
syn cluster dqMode contains=NONE

source <sfile>:h/lib-comment-string.vim
