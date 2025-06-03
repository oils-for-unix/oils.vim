" Vim syntax file
" Language: YSH
"
" Claude AI helped a lot here, because vim config confuses me
" But I've kept this initial version very bare-bones.  We can iterate on it.
"
" Larger version, with a few issues: https://github.com/sj2tpgk/vim-oil

if exists("b:current_syntax")
  finish
endif

" This avoids problems with long multiline strings
:syntax sync minlines=200

syn keyword shellKeyword if elif else case for while

" YSH keywords
syn keyword yshKeyword proc func const var setvar setglobal call break continue return
" = keyword occurs at the beginning of a line
syn match equalsKeyword '^[ \t]*=[ ]'

" End-of-line comments
syn match yshComment '^#.*$'
syn match yshComment '[ \t]#.*$'

syn match backslashSq "\\'"
syn match backslashDq '\\"'

" Raw strings - \< means word boundary, which isn't exactly right, but it's
" better than not including it 
syn region rawString start="\<r'" end="'"

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region sqString start="'" end="'"

" Double-quoted strings
" minimal style omits 'contains=yshInterpolation'
syn region dqString start='"' skip='\\.' end='"' 

" Explicit with $
" minimal style omits 'contains=yshInterpolation'
syn region dollarDqString start='$"' skip='\\.' end='"'

" Python-like triple-quoted strings
syn region tripleRawString start="\<r'''" end="'''"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region tripleSqString start="'''" end="'''"
" minimal style omits 'contains=yshInterpolation'
syn region tripleDqString start='"""' end='"""'
syn region tripleDollarDqString start='$"""' end='"""'

" String interpolation within double quotes
syn match yshInterpolation "\$\w\+"

" Define highlighting
hi def link yshComment Comment

hi def link shellKeyword Keyword
hi def link yshKeyword Keyword
hi def link equalsKeyword Keyword

hi def link rawString String
hi def link j8String String
hi def link sqString String
hi def link dqString String
hi def link dollarDqString String

hi def link tripleRawString String
hi def link tripleJ8String String
hi def link tripleSqString String
hi def link tripleDqString String
hi def link tripleDollarDqString String

hi def link yshInterpolation Special

hi def link backslashDq Character
hi def link backslashSq Character

let b:current_syntax = "ysh"
