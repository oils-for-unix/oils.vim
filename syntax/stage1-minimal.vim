" Vim syntax definition for YSH
" This is stage 1 - Lex Comments and String Literals.  See checklist.md.

" You can quote the special characters for comments and string literals
syn match backslashQuoted /\\[#'"\\]/

" End-of-line comments
syn match yshComment '^#.*$'
syn match yshComment '[ \t]#.*$'

"
" 5 kinds of string literal
"

" Raw strings - \< means word boundary, which isn't exactly right, but it's
" better than not including it 
" The problem is --foo=r'bar' -- TODO: document this quirk
syn region rawString start="\<r'" end="'"

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region sqString start="'" end="'"

" Double-quoted strings
syn region dqString start='"' skip='\\.' end='"' 

" Explicit with $
syn region dollarDqString start='$"' skip='\\.' end='"'

"
" 5 multi-line variants (triple-quoted like Python)
"

syn region tripleRawString start="\<r'''" end="'''"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region tripleSqString start="'''" end="'''"
syn region tripleDqString start='"""' end='"""'
syn region tripleDollarDqString start='$"""' end='"""'

"
" Define highlighting
"

hi def link backslashQuoted Character

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
