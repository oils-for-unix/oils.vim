" Vim syntax definition for YSH
" Stage 3 - Recognize Details Within Each Mode

"
" Libraries
"

source <sfile>:h/lib-vim-clusters.vim
source <sfile>:h/lib-comment-string.vim
" recursive modes
source <sfile>:h/lib-command-expr-dq.vim  
source <sfile>:h/lib-sub-splice.vim 

"
" Backslashes and Comments
"

syn match backslashQuoted /\\[#'"$@()\\]/
" For clarity, denote \[ \] separately
syn match backslashQuoted '\\\['
syn match backslashQuoted '\\]'

hi def link backslashQuoted Character
