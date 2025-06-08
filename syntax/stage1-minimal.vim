" Vim syntax definition for YSH
" Stage 1 - Lex Comments and String Literals

" You can quote the special characters for comments and string literals
syn match backslashQuoted /\\[#'"\\]/
hi def link backslashQuoted Character

" Note: this file reference the @dqMode cluster, which we don't define.  But
" it's OK because Vim ignores it, and everything else still works.

source <sfile>:h/lib-comment-string.vim
