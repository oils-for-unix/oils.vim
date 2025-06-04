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
syn match backslashDollar '\\\$'
syn match backslashAt '\\@'

syn cluster quotedStrings 
      \ contains=rawString,j8String,sqString,dqString,dollarDqString
syn cluster tripleQuotedStrings 
      \ contains=tripleRawString,tripleJ8String,tripleSqString,tripleDqString,tripleDollarDqString

" $(echo hi) and $[42 + a[i]] are allowed in all kinds of double quoted strings
syn cluster dqSub
      \ contains=simpleVarSub,exprSub,commandSub

" Raw strings - \< means word boundary, which isn't exactly right, but it's
" better than not including it 
syn region rawString start="\<r'" end="'"

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region sqString start="'" end="'"

" Double-quoted strings
syn region dqString start='"' skip='\\.' end='"' 
      \ contains=@dqSub

" Explicit with $
syn region dollarDqString start='\$"' skip='\\.' end='"' 
      \ contains=@dqSub

syn cluster expr 
      \ contains=caretDqString,exprSub,exprSplice,commandSub,commandSplice,caretCommand
 
syn region caretDqString start='\^"' skip='\\.' end='"' 
      \ contains=@dqSub

" Python-like triple-quoted strings
syn region tripleRawString start="\<r'''" end="'''"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region tripleSqString start="'''" end="'''"
syn region tripleDqString start='"""' end='"""' 
      \ contains=@dqSub
syn region tripleDollarDqString start='$"""' end='"""' 
      \ contains=@dqSub

" String interpolation within double quotes
syn match simpleVarSub '\$\w\+'

syn cluster nested contains=nestedParen,nestedBracket,nestedBrace

" nested () [] {}
" used for
"   pp (x)  # nestedParen contained
"   pp [x]  # nestedBracket contained
" Could improve this
syn region nestedParen start='(' end=')' skip='\\[()]'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,@expr "contained
syn region nestedBracket start='\[' end=']' skip='\\[\[\]]'
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings,@expr "contained

syn region nestedBrace start='{' end='}' skip='\\[{}]' 
      \ contains=nestedBrace,@quotedStrings,@tripleQuotedStrings,@expr contained

" rhsExpr starts with =
" and ends with
" - a comment, with me=s-2 for ending BEFORE the #
" - semicolon ; with me=s-1
" - end of line
syn region rhsExpr start='= ' end=' #'me=s-2 end=';'me=s-1 end='$' 
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings,@expr
" note: call is the same as =, but the 'call' keyword also interferes

" $[a[i]] contains nestedBracket to match []
" matchgroup= is necessary for $[] to contain [] correctly
syn region exprSub matchgroup=Identifier start='\$\[' end=']'
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings,@expr
syn region exprSplice matchgroup=Identifier start='@\[' end=']'
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings

syn region commandSub matchgroup=Identifier start='\$(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings
syn region commandSplice matchgroup=Identifier start='@(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings
syn region caretCommand matchgroup=Identifier start='\^(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings

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

" expression only
hi def link caretDqString String

" @quotedStrings
hi def link rawString String
hi def link j8String String
hi def link sqString String
hi def link dqString String
hi def link dollarDqString String

" @tripleQuotedStrings
hi def link tripleRawString String
hi def link tripleJ8String String
hi def link tripleSqString String
hi def link tripleDqString String
hi def link tripleDollarDqString String

hi def link simpleVarSub Identifier

hi def link backslashDq Character
hi def link backslashSq Character
hi def link backslashDollar Character
hi def link backslashAt Character

hi def link exprSub Special
hi def link exprSplice Special

hi def link nestedParen Special
hi def link nestedBracket Special
hi def link nestedBrace Special
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
