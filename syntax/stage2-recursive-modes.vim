" Vim syntax definition for YSH
" Stage 2 - Correctly Switch Between Three Lexer Modes

"
" Libraries
"

source <sfile>:h/lib-vim-clusters.vim
source <sfile>:h/lib-comment-string.vim
" recursive modes
source <sfile>:h/lib-command-expr-dq.vim  
"source <sfile>:h/lib-sub-splice.vim 

"
" Backslashes and Comments
"

syn match backslashQuoted /\\[#'"$@()\\]/
" For clarity, denote \[ \] separately
syn match backslashQuoted '\\\['
syn match backslashQuoted '\\]'

hi def link backslashQuoted Character
