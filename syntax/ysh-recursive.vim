" Vim syntax definition for YSH
" This is stage 2 - mutually recursive commands, strings, and expressions.
" See checklist.md.
"
" Note: my vimrc overrides these colors:
"
" let g:ysh_expr_color = 20        " blue  
" let g:ysh_sigil_pair_color = 55  " purple
" let g:ysh_var_sub_color = 89     " lighter purple

" let g:ysh_proc_name_color = 55   " purple
" let g:ysh_func_name_color = 89   " lighter purple

syn keyword shellKeyword if elif else case for while
syn keyword yshKeyword const var setvar setglobal break continue return

" The call and = keywords are followed by an expression
syn keyword callKeyword call nextgroup=exprAfterKeyword 
" The = keyword occurs at the beginning of a line (different than rhsExpr)
syn match equalsKeyword '^[ \t]*=' nextgroup=exprAfterKeyword

syn keyword funcKeyword func nextgroup=funcName skipwhite
syn keyword procKeyword proc nextgroup=procName skipwhite

" skipwhite seems necessary to avoid conflict with typedArgs start=' ('
syn match funcName '[a-zA-Z_][a-zA-Z0-9_]*' contained skipwhite nextgroup=paramList
" also allow hyphens
syn match procName '[a-zA-Z_-][a-zA-Z0-9_-]*' contained skipwhite nextgroup=paramList

" End-of-line comments
syn match yshComment '^#.*$'
syn match yshComment '[ \t]#.*$'

" TODO: could refine this, but it's enough for segmentation / nested pairs / sigil pairs
syn match backslashQuoted /\\[#'"$@()\[\]]/

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

syn cluster nested contains=nestedParen,nestedBracket,nestedBrace

" nested () [] {}
" used for
"   pp (x)  # nestedParen not contained
"   pp [x]  # nestedBracket not contained
" Could improve this
syn region nestedParen matchgroup=nestedPair start='(' end=')' transparent
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,@expr
syn region nestedBracket matchgroup=nestedPair start='\[' end=']' transparent
      \ contains=nestedBracket,@quotedStrings,@tripleQuotedStrings,@expr

" TODO: why is {} colored Special, when the nestedPair should be Normal?
" This is only used for expressions, not for command blocks { }
" skip='\\[{}]' could be useful
syn region nestedBrace matchgroup=nestedPair start='{' end='}' transparent
      \ contains=nestedBrace,@quotedStrings,@tripleQuotedStrings,@expr contained

" for func and proc signatures
syn region paramList matchgroup=Normal start='(' end=')' contained
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings,@expr

" pp (x) space before (
syn region typedArgs matchgroup=Normal start=' (' end=')' 
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings,@expr

" pp [x] space before [
syn region lazyTypedArgs matchgroup=Normal start=' \[' end=']' 
     \ contains=@nested,@quotedStrings,@tripleQuotedStrings,@expr

" rhsExpr starts with ' = ' (leading space distinguishes from = keyword)
" and ends with
" - a comment, with me=s-2 for ending BEFORE the #
" - semicolon ; with me=s-1
" - end of line
" matchgroup=Normal prevents = from being highlighted
syn region rhsExpr matchgroup=Normal start=' = ' end=' #'me=s-2 end=';'me=s-1 end='$'
      \ contains=@nested,@quotedStrings,@tripleQuotedStrings,@expr
syn region exprAfterKeyword start='\s' end=' #'me=s-2 end=';'me=s-1 end='$' contained
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

" note: could contain typedArgs,lazyTypedArgs, all keywords etc.  But
" nestedParen,backslashQuoted,yshComment is enough to match parens.
syn region commandSub matchgroup=sigilPair start='\$(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,backslashQuoted,yshComment
syn region commandSplice matchgroup=sigilPair start='@(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,backslashQuoted,yshComment
syn region caretCommand matchgroup=sigilPair start='\^(' end=')'
      \ contains=nestedParen,@quotedStrings,@tripleQuotedStrings,backslashQuoted,yshComment

" var x = :| README *.py | 
" Vim quirk: | is a pipe, and \| is the regex operator
syn region yshArrayLiteral matchgroup=sigilPair start=':|' end='|'
      \ contains=@quotedStrings,@tripleQuotedStrings,@splice,@dollarSub,backslashQuoted

"
" Step 3: Highlight Details
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

"
" Define Standard Syntax Groups
"   Normal Comment Keyword Character String Identifier
"

hi def link yshComment Comment

hi def link shellKeyword Keyword
hi def link yshKeyword Keyword
hi def link callKeyword Keyword
hi def link equalsKeyword Keyword

hi def link funcKeyword Keyword
hi def link procKeyword Keyword

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

hi def link yshArrayLiteral Normal

" I might change nestedPair, so not allow overriding it
hi def link nestedPair Normal


" Define Custom Syntax Groups
"   yshVarSub yshExpr

hi def link varSubName yshVarSub
hi def link varSubBracedName yshVarSub
hi def link varSubNumber yshVarSub
hi def link varSubBracedNumber yshVarSub
" @array_splice is considered var sub
hi def link varSplice yshVarSub

hi def link exprSub yshExpr
hi def link exprSplice yshExpr
hi def link caretExpr yshExpr

"hi def link nestedParen yshExpr
"hi def link nestedBracket yshExpr
"hi def link nestedBrace yshExpr

hi def link rhsExpr yshExpr
hi def link exprAfterKeyword yshExpr

hi def link typedArgs yshExpr
hi def link lazyTypedArgs yshExpr

hi def link paramList Normal

" These groups can be assigned custom colors:
"   yshVarSub yshExpr sigilPair

if exists('g:ysh_func_name_color')
  execute 'highlight funcName ctermfg=' . g:ysh_func_name_color
else
  hi def link funcName Function
endif

if exists('g:ysh_proc_name_color')
  execute 'highlight procName ctermfg=' . g:ysh_proc_name_color
else
  hi def link procName Function
endif

" yshExpr:  f(x, a[i])
if exists('g:ysh_expr_color')
  execute 'highlight yshExpr ctermfg=' . g:ysh_expr_color
else
  " an expression is like typed data
  hi def link yshExpr Type
  " hi def link yshExpr Function
endif

" yshVarSub:  "hi $x"
if exists('g:ysh_var_sub_color')
  execute 'highlight yshVarSub ctermfg=' . g:ysh_var_sub_color
else
  hi def link yshVarSub Identifier
endif

" sigilPair:  $(echo hi)
if exists('g:ysh_sigil_pair_color')
  execute 'highlight sigilPair ctermfg=' . g:ysh_sigil_pair_color
else
  hi def link sigilPair Special
endif
