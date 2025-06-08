"
" Substitutions, splicing
"

" $name
syn match varSubName '\$[a-zA-Z_][a-zA-Z0-9_]*'
" ${name}
syn match varSubBracedName '\${[a-zA-Z_][a-zA-Z0-9_]*}'
" $1 is valid, but not $11.  Should be ${11}
syn match varSubNumber '\$[0-9]'
" ${12}
" Vim quirk: it's [0-9]\+ versus [0-9]*.  Use * to keep our metalangauge simple
syn match varSubBracedNumber '\${[0-9][0-9]*}'

" @splice - \< word boundary doesn't work because @ is a non-word char
" Use 2 patterns to avoid complex \z expressions
syn match varSplice '[ \t]@[a-zA-Z_][a-zA-Z0-9_]*'
syn match varSplice '^@[a-zA-Z_][a-zA-Z0-9_]*'

hi def link varSubName yshVarSub
hi def link varSubBracedName yshVarSub
hi def link varSubNumber yshVarSub
hi def link varSubBracedNumber yshVarSub
" @array_splice is considered var sub
hi def link varSplice yshVarSub

" TODO:
" - ${x %03d} and %{12 %03d}
" - $$ $- ...
"


"
" Expression Keywords
"

" consult frontend/lexer_def.py
syn keyword exprAtom contained null true false
syn keyword exprKeyword contained and or not for is in if else func proc capture as

hi def link exprAtom Constant
hi def link exprKeyword Keyword
