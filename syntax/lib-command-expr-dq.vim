"
" Keywords (call and = take expressions)
"

syn keyword shellKeyword if elif else case while for in
syn keyword yshKeyword break continue return

" TODO: these should also be anchored to the beginning of a line
syn keyword yshKeyword const var setvar setglobal 

" Here \( \| \) are regex operators, because \v 'very magic' mode doesn't work
" with \> ?  This seems like a Vim 9 bug?
let firstWord = '\(^\|[;|&]\)'  " beginning of line or ; or | or &
let space = '\s*'
let startMatch = '\zs'

let firstWordPrefix = firstWord . space . startMatch

let endWord = '\>'

" call f(x)
let callRegex = $"{firstWordPrefix}call{endWord}"
execute 'syn match callKeyword "' . callRegex . '" nextgroup=exprAfterKeyword'

" = f(x)  # handled differently than rhsExpr
let equalsRegex = $"{firstWordPrefix}="
execute 'syn match equalsKeyword "' . equalsRegex . '" nextgroup=exprAfterKeyword'

syn keyword funcKeyword func nextgroup=funcName skipwhite
syn keyword procKeyword proc nextgroup=procName skipwhite

hi def link shellKeyword Keyword
hi def link yshKeyword Keyword
hi def link callKeyword Keyword
hi def link equalsKeyword Keyword

hi def link funcKeyword Keyword
hi def link procKeyword Keyword

" skipwhite seems necessary to avoid conflict with spaceParen start=' ('
syn match funcName '[a-zA-Z_][a-zA-Z0-9_]*' contained skipwhite nextgroup=paramList
" also allow hyphens
syn match procName '[a-zA-Z_-][a-zA-Z0-9_-]*' contained skipwhite nextgroup=paramList

" ^"" - string literal that only appears in expression mode
syn region caretDqString matchgroup=sigilPair start='\^"' skip='\\.' end='"' 
      \ contains=@dqMode

" expression only
hi def link caretDqString String

" 
" Nested () [] {} for multi-line expressions
"

syn region nestedParen matchgroup=nestedPair start='(' end=')' transparent contained
      \ contains=@nested,@exprMode
syn region nestedBracket matchgroup=nestedPair start='\[' end=']' transparent contained
      \ contains=@nested,@exprMode

" TODO: why is {} colored Special, when the nestedPair should be Normal?
" This is only used for expressions, not for command blocks { }
" skip='\\[{}]' could be useful
syn region nestedBrace matchgroup=nestedPair start='{' end='}' transparent contained
      \ contains=@nested,@exprMode

"
" Command Mode --> Expression (and Params)
"

" func myFunc(x, y) { return (x) }
" proc my-proc (x, y) { echo }
syn region paramList matchgroup=Normal start='(' end=')' contained
      \ contains=@nested,@exprMode

" pp (x) - space before (
" if (x)
" return (x)
syn region spaceParen matchgroup=Normal start=' (' end=')' 
      \ contains=@nested,@exprMode

" pp [x] - space before [
syn region lazyTypedArgs matchgroup=Normal start=' \[' end=']' 
     \ contains=@nested,@exprMode

" var x = f(42, a[i])
" rhsExpr starts with ' = ' (leading space distinguishes from = keyword)
" and ends with
" - a comment, with me=s-2 for ending BEFORE the #
" - semicolon ; with me=s-1
" - end of line
" matchgroup=Normal prevents = from being highlighted
syn region rhsExpr matchgroup=Normal start=' = ' end=' #'me=s-2 end=';'me=s-1 end='$'
      \ contains=@nested,@exprMode

" call f(x)
" = f(x)
syn region exprAfterKeyword start='\s' end=' #'me=s-2 end=';'me=s-1 end='$' contained
      \ contains=@nested,@exprMode
" note: call is the same as =, but the 'call' keyword also interferes

"
" --> Expression Mode
"
" Sigil Pairs $[] @[] ^[]

" $[a[i]] contains nestedBracket to match []
" matchgroup= is necessary for $[] to contain [] correctly
syn region exprSub matchgroup=sigilPair start='\$\[' end=']'
      \ contains=nestedBracket,@exprMode
syn region exprSplice matchgroup=sigilPair start='@\[' end=']'
      \ contains=nestedBracket,@exprMode
syn region caretExpr matchgroup=sigilPair start='\^\[' end=']'
      \ contains=nestedBracket,@exprMode

"
" --> Command Mode
"
" Sigil Pairs $() @() ^()

" $(pp (42)) requires contains=nestedParen
syn region commandSub matchgroup=sigilPair start='\$(' end=')'
      \ contains=nestedParen,@commandMode
syn region commandSplice matchgroup=sigilPair start='@(' end=')'
      \ contains=nestedParen,@commandMode
syn region caretCommand matchgroup=sigilPair start='\^(' end=')'
      \ contains=nestedParen,@commandMode

"
" Expression Mode -> Array Mode
"

" var x = :| README *.py | 
" Vim quirk: | is a pipe, and \| is the regex operator
syn region yshArrayLiteral matchgroup=sigilPair start=':|' end='|'
      \ contains=@arrayMode

"
" Define Standard Syntax Groups
"   Normal Comment Keyword Character String Identifier
"

hi def link yshArrayLiteral Normal

" Could allow overriding this
hi def link nestedPair Normal

" Define Custom Syntax Groups
"   yshVarSub yshExpr

hi def link exprSub yshExpr
hi def link exprSplice yshExpr
hi def link caretExpr yshExpr

hi def link rhsExpr yshExpr
hi def link exprAfterKeyword yshExpr

hi def link spaceParen yshExpr
hi def link lazyTypedArgs yshExpr

hi def link paramList Normal

" These groups can be assigned custom colors:
"   funcName procName yshVarSub yshExpr sigilPair

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
