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
" disabled since it interfers with rhsExpr
" syn match equalsKeyword '^[ \t]*=[ ]'

" End-of-line comments
syn match yshComment '^#.*$'
syn match yshComment '[ \t]#.*$'

syn match backslashSq "\\'"
syn match backslashDq '\\"'

syn cluster quotedStrings contains=rawString,j8String,sqString,dqString,dollarDqString
syn cluster tripleQuotedStrings contains=tripleRawString,tripleJ8String,tripleSqString,tripleDqString,tripleDollarDqString

" Raw strings - \< means word boundary, which isn't exactly right, but it's
" better than not including it 
syn region rawString start="\<r'" end="'"

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region sqString start="'" end="'"

" Double-quoted strings
syn region dqString start='"' skip='\\.' end='"' contains=yshInterpolation

" Explicit with $
syn region dollarDqString start='$"' skip='\\.' end='"' contains=yshInterpolation

" Python-like triple-quoted strings
syn region tripleRawString start="\<r'''" end="'''"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region tripleSqString start="'''" end="'''"
syn region tripleDqString start='"""' end='"""' contains=yshInterpolation
syn region tripleDollarDqString start='$"""' end='"""' contains=yshInterpolation

" String interpolation within double quotes
syn match yshInterpolation "\$\w\+"

syn cluster nested contains=nestedParen,nestedBracket,nestedBrace

" pp (x)
" space required - pp(x) is illegal - it would be call pp(x)
" syn region exprParen start='[ \t](' end=')' skip='\\[()]' contains=exprParen,@quotedStrings,@tripleQuotedStrings
syn region nestedParen start='(' end=')' skip='\\[()]' contains=@nested,@quotedStrings,@tripleQuotedStrings contained

" space required before pp [x], it is different than *.[ch]
" is the right syntax for \[ or \]?
" syn region exprBracket start='[ \t]\[' end=']' skip='\\[\[\]]' contains=exprBracket,@quotedStrings,@tripleQuotedStrings
syn region nestedBracket start='\[' end=']' skip='\\[\[\]]' contains=@nested,@quotedStrings,@tripleQuotedStrings contained

syn region nestedBrace start='{' end='}' skip='\\[{}]' contains=@nested,@quotedStrings,@tripleQuotedStrings contained

syn region rhsExpr start='= ' end='$' contains=@nested,@quotedStrings,@tripleQuotedStrings

" Define highlighting
hi def link yshComment Comment

hi def link shellKeyword Keyword
hi def link yshKeyword Keyword
" hi def link equalsKeyword Keyword

hi def link @quotedStrings String

hi def link @tripleQuotedStrings String

hi def link yshInterpolation Identifier

hi def link backslashDq Character
hi def link backslashSq Character

hi def link @nested Special
hi def link rhsExpr String

" hi def link nestedParen Special
" hi def link nestedBracket Special
" hi def link nestedBrace Special


let b:current_syntax = "ysh"

" Function that displays the stack of lexer modes under the cursor
" :call SynStack()
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
