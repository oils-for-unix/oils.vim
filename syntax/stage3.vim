" Vim syntax definition for YSH
" Stage 3 - Recognize Details Within Each Mode

"
" More Backslash Quotes Than Stage 1 or 2
"

syn match backslashQuoted /\\[#'"$@(){}\\]/
" For clarity, denote \[ \] separately
syn match backslashQuoted '\\\['
syn match backslashQuoted '\\]'

hi def link backslashQuoted Character

"
" Libraries
"

source <sfile>:h/lib-vim-clusters.vim
source <sfile>:h/lib-comment-string.vim
" recursive lexer modes
source <sfile>:h/lib-command-expr-dq.vim  
source <sfile>:h/lib-details.vim 

