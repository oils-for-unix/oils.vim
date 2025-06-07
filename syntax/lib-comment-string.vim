" End-of-line comments
syn match yshComment '^#.*$'
syn match yshComment '[ \t]#.*$'

hi def link yshComment Comment

"
" 5 kinds of string literal
"

" \< means word boundary, which isn't right for
" --foo=r'bar'
" --foo=u'bar'

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Raw strings are single quoted, with optional r prefix
syn region rawString start="\<r'" end="'"
syn region sqString start="'" end="'"

" Double-quoted strings, with optional $ prefix
syn region dqString start='"' skip='\\.' end='"' 
      \ contains=@dqMode
syn region dollarDqString start='$"' skip='\\.' end='"'
      \ contains=@dqMode

hi def link rawString String
hi def link j8String String
hi def link sqString String
hi def link dqString String
hi def link dollarDqString String

"
" 5 multi-line variants (triple-quoted like Python)
"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region tripleRawString start="\<r'''" end="'''"
syn region tripleSqString start="'''" end="'''"
syn region tripleDqString start='"""' skip='\\.' end='"""'
      \ contains=@dqMode
syn region tripleDollarDqString start='$"""' skip='\\.' end='"""'
      \ contains=@dqMode

hi def link tripleRawString String
hi def link tripleJ8String String
hi def link tripleSqString String
hi def link tripleDqString String
hi def link tripleDollarDqString String
