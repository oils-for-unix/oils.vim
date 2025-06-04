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

syn cluster quotedStrings 
      \ contains=rawString,j8String,sqString,dqString,dollarDqString
syn cluster tripleQuotedStrings 
      \ contains=tripleRawString,tripleJ8String,tripleSqString,tripleDqString,tripleDollarDqString

" Raw strings - \< means word boundary, which isn't exactly right, but it's
" better than not including it 
syn region rawString start="\<r'" end="'"

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region sqString start="'" end="'"

" Double-quoted strings
syn region dqString start='"' skip='\\.' end='"' 
      \ contains=simpleVarSub

" Explicit with $
syn region dollarDqString start='$"' skip='\\.' end='"' 
      \ contains=simpleVarSub

" Python-like triple-quoted strings
syn region tripleRawString start="\<r'''" end="'''"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region tripleSqString start="'''" end="'''"
syn region tripleDqString start='"""' end='"""' 
      \ contains=simpleVarSub
syn region tripleDollarDqString start='$"""' end='"""' 
      \ contains=simpleVarSub

" String interpolation within double quotes
syn match simpleVarSub "\$\w\+"

syn cluster nested contains=nestedParen,nestedBracket,nestedBrace

syn region nestedParen start='(' end=')' skip='\\[()]'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings "contained
      "\ contains=nestedParen,@quotedStrings,@tripleQuotedStrings contained
syn region nestedBracket start='\[' end=']' skip='\\[\[\]]'
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings "contained

syn region nestedBrace start='{' end='}' skip='\\[{}]' 
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings contained

" a rhsExpr starts with = and ends with
" - a comment, with a special me=s-2 for ending BEFORE the #
" - semicolon ;
" - end of line
syn region rhsExpr start='= ' end=' #'me=s-2 end=';'me=s-1 end='$' 
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings
" note: call is the same as =, but the 'call' keyword also interferes

" pp (f(x))
" syn region typedArgs start=' (' end=')' contains=@nested,@quotedStrings,@tripleQuotedStrings
" syn region typedArgs start='(' end=')' contains=nestedParen
" hi def link typedArgs Special

" space first
" syn region lazyTypedArgs start=' \[' end=']' 
"      \ contains=@nested,@quotedStrings,@tripleQuotedStrings

" Define highlighting
hi def link yshComment Comment

hi def link shellKeyword Keyword
hi def link yshKeyword Keyword
" hi def link equalsKeyword Keyword

hi def link @quotedStrings String

hi def link @tripleQuotedStrings String

hi def link simpleVarSub Identifier

hi def link backslashDq Character
hi def link backslashSq Character

hi def link @nested Special
hi def link rhsExpr String

let b:current_syntax = "ysh"

" Function that displays the stack of lexer modes under the cursor
" :call SynStack()
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
