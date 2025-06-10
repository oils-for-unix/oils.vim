" Vim syntax definition for YSH
" Stage 2 - Correctly Switch Between Three Lexer Modes

"
" More Backslash Quotes Than Stage 1
"

syn match backslashQuoted /\\[#'"$@()\\]/
" For clarity, denote \[ \] separately
syn match backslashQuoted '\\\['
syn match backslashQuoted '\\]'

hi def link backslashQuoted Character

"
" Libraries
"

source <sfile>:h/lexer-modes.vim
source <sfile>:h/lib-comment-string.vim
" recursive lexer modes
source <sfile>:h/lib-command-expr-dq.vim  

