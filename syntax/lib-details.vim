source <sfile>:h/lib-regex.vim

"
" Substitutions, splicing
"

" $name
let regex = '\v\$' . varNameRegex 
execute 'syn match varSubName "' . regex . '"'

" ${name} and ${name %3d} (not recursive)
" \v so \{ is literal
let regex = '\v\$\{' . varNameRegex . '[^}]*\}'
execute 'syn match varSubBracedName "' . regex . '"'

" $1 is valid, but not $11.  Should be ${11}
syn match varSubNumber '\$[0-9]'
" ${12} and ${12 %3d}
" \v means + is an operator
syn match varSubBracedNumber '\v\$\{[0-9]+[^}]*\}'

" @splice at beginning of line or preceded by space
" \< word boundary doesn't work because @ is a non-word char
let regex = '\v(^|\s)\@' . varNameRegex
execute 'syn match varSplice "' . regex . '"'

hi def link varSubName yshVarSub
hi def link varSubBracedName yshVarSub
hi def link varSubNumber yshVarSub
hi def link varSubBracedNumber yshVarSub
" @array_splice is considered var sub
hi def link varSplice yshVarSub

" TODO: $$ $- ...


"
" Expression Keywords
"

" consult frontend/lexer_def.py
syn keyword exprAtom contained null true false
syn keyword exprKeyword contained and or not for is in if else func proc capture as

hi def link exprAtom Constant
hi def link exprKeyword Keyword

"
" J8 strings
"

" Bad backslash escape - must come first
syn match j8_Error '\\.' contained
hi def link j8_Error Error

" J8 string escapes from frontend/lexer_def.py
syn match jsonOneChar '\\[\\"/bfnrt]' contained
syn match j8_OneChar "\\'" contained

" \v means that {1,6} is an operator
syn match j8_YHex '\v\\y[0-9a-fA-F]{2}' contained
syn match j8_UBraced '\v\\[uU]\{[0-9a-fA-F]{1,6}\}' contained

" Keep it normal, opposite of String
" hi def link jsonOneChar Character
" hi def link j8_OneChar Character
" hi def link j8_YHex Character
" hi def link j8_UBraced Character
