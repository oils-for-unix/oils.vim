" Vim syntax definition for YSH
" This is stage 2 - mutually recursive commands, strings, and expressions.  See checklist.md.

if exists("b:current_syntax")
  finish
endif

" This avoids problems with long multiline strings
:syntax sync minlines=200

syn keyword shellKeyword if elif else case for while
syn keyword yshKeyword proc func const var setvar setglobal call break continue return

" = keyword occurs at the beginning of a line
" disabled since it interfers with rhsExpr
" syn match equalsKeyword '^[ \t]*=[ ]'

" End-of-line comments
syn match yshComment '^#.*$'
syn match yshComment '[ \t]#.*$'

" TODO: could refine this, but it is enough for segmentation / nested pairs / sigil pairs
syn match backslashQuoted /\\['"$@()\[\]]/

syn cluster quotedStrings
      \ contains=rawString,j8String,sqString,dqString,dollarDqString
syn cluster tripleQuotedStrings 
      \ contains=tripleRawString,tripleJ8String,tripleSqString,tripleDqString,tripleDollarDqString

" note: expressions can't have varSubName
syn cluster dollarSubInExpr
      \ contains=varSubBracedName,varSubNumber,varSubBracedNumber,commandSub,exprSub
syn cluster dollarSub
      \ contains=varSubName,@dollarSubInExpr

syn cluster splice
      \ contains=varSplice,exprSplice,commandSplice

syn cluster expr 
      \ contains=@dollarSubInExpr,@splice,caretDqString,caretCommand,caretExpr,yshArrayLiteral

" Raw strings - \< means word boundary, which isn't exactly right, but it's
" better than not including it 
syn region rawString start="\<r'" end="'"

" J8-style b'' or u''
syn region j8String start="\<[bu]'" skip='\\.' end="'"

" Single-quoted string
syn region sqString start="'" end="'"

" Double-quoted strings
syn region dqString start='"' skip='\\.' end='"' 
      \ contains=@dollarSub

" Explicit with $
syn region dollarDqString start='\$"' skip='\\.' end='"' 
      \ contains=@dollarSub

syn region caretDqString matchgroup=sigilPair start='\^"' skip='\\.' end='"' 
      \ contains=@dollarSub

" 5 triple-quoted variants of the above (Python-like)
syn region tripleRawString start="\<r'''" end="'''"
syn region tripleJ8String start="\<[bu]'''" skip='\\.' end="'''"
syn region tripleSqString start="'''" end="'''"
syn region tripleDqString start='"""' end='"""' 
      \ contains=@dollarSub
syn region tripleDollarDqString start='$"""' end='"""' 
      \ contains=@dollarSub

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

syn cluster nested contains=nestedParen,nestedBracket,nestedBrace

" nested () [] {}
" used for
"   pp (x)  # nestedParen not contained
"   pp [x]  # nestedBracket not contained
" Could improve this
syn region nestedParen matchgroup=nestedPair start='(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,@expr
syn region nestedBracket matchgroup=nestedPair start='\[' end=']'
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings,@expr

" TODO: why is {} colored Special, when the nestedPair should be Normal?
" This is only used for expressions, not for command blocks { }
" skip='\\[{}]' could be useful
syn region nestedBrace matchgroup=nestedPair start='{' end='}'
      \ contains=nestedBrace,@quotedStrings,@tripleQuotedStrings,@expr contained

" Can we do something more accurate?  Space before ( and [

" syn region typedArgs start=' (' end=')' contains=@nested,@quotedStrings,@tripleQuotedStrings
" syn region typedArgs start='(' end=')' contains=nestedParen
" hi def link typedArgs Special

" syn region lazyTypedArgs start=' \[' end=']' 
"      \ contains=@nested,@quotedStrings,@tripleQuotedStrings

" rhsExpr starts with =
" and ends with
" - a comment, with me=s-2 for ending BEFORE the #
" - semicolon ; with me=s-1
" - end of line
syn region rhsExpr matchgroup=Normal start='= ' end=' #'me=s-2 end=';'me=s-1 end='$'
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings,@expr
" note: call is the same as =, but the 'call' keyword also interferes

" Sigil Pairs $[] @[] ^[]

" $[a[i]] contains nestedBracket to match []
" matchgroup= is necessary for $[] to contain [] correctly
syn region exprSub matchgroup=sigilPair start='\$\[' end=']'
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings,@expr
syn region exprSplice matchgroup=sigilPair start='@\[' end=']'
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings
syn region caretExpr matchgroup=sigilPair start='\^\[' end=']'
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings

" Sigil Pairs $() @() ^()

syn region commandSub matchgroup=sigilPair start='\$(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,backslashQuoted
syn region commandSplice matchgroup=sigilPair start='@(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,backslashQuoted
syn region caretCommand matchgroup=sigilPair start='\^(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,backslashQuoted

" var x = :| README *.py | 
" Vim quirk: | is a pipe, and \| is the regex operator
syn region yshArrayLiteral matchgroup=sigilPair start=':|' end='|'
      \ contains=@quotedStrings,@tripleQuotedStrings,@splice,@dollarSub,backslashQuoted

" Define highlighting
hi def link yshComment Comment

hi def link shellKeyword Keyword
hi def link yshKeyword Keyword
" hi def link equalsKeyword Keyword

hi def link backslashQuoted Character

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

hi def link varSubName Identifier
hi def link varSubBracedName Identifier
hi def link varSubNumber Identifier
hi def link varSubBracedNumber Identifier

hi def link varSplice Identifier

hi def link exprSub yshExpr
hi def link exprSplice yshExpr

hi def link nestedParen yshExpr
hi def link nestedBracket yshExpr
hi def link nestedBrace yshExpr

hi def link rhsExpr yshExpr

hi def link nestedPair Normal
hi def link sigilPair Special

" highlighted like a command
hi def link yshArrayLiteral Normal

hi def link yshExpr Function
" highlight yshExpr ctermfg=green guifg=green

let b:current_syntax = "ysh"

" Function that displays the stack of lexer modes under the cursor
" :call SynStack()
function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
