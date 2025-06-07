
" everything here is valid
source <sfile>:h/stage2-recursive-modes.vim

" Problem: needs to be hooked up to @exprMode cluster

syn keyword exprAtom null true false
syn keyword exprKeyword and or not for is in if else capture as func proc

hi def link exprAtom Boolean
hi def link exprKeyword Keyword


