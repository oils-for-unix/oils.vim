"
" Cluster definitions
"
" Note: we rely on the fact that undefined clusters are ignored.
" For example, stage2 doesn't have varSubName,varSubBracedName, etc.  But it
" degrades gracefully, and doesn't break other behavior.

" Multi-line expressions: var x = f(42,
"                                   [99], {})
syn cluster nested contains=nestedParen,nestedBracket,nestedBrace

" r' u' $"
syn cluster quotedStrings
      \ contains=rawString,j8String,sqString,dqString,dollarDqString
" r''' u""" $"""
syn cluster tripleQuotedStrings 
      \ contains=tripleRawString,tripleJ8String,tripleSqString,tripleDqString,tripleDollarDqString
syn cluster strings
      \ contains=@quotedStrings,@tripleQuotedStrings

" @array @[array] @(seq 3)
syn cluster splice
      \ contains=varSplice,exprSplice,commandSplice

" ^"" ^() ^[]
syn cluster caret
      \ contains=caretDqString,caretCommand,caretExpr

" ${name} $0 ${12} $(echo hi) $[42 + a[i]]
" note: expressions can't have varSubName
syn cluster dollarSubInExpr
      \ contains=varSubBracedName,varSubNumber,varSubBracedNumber,commandSub,exprSub

"
" Main lexer modes (clusters): DQ, array, command, expr
"

syn cluster dqMode
      \ contains=varSubName,@dollarSubInExpr

" arrayMode/commandMode contain everything in @dqMode
" arrayMode may also have {a,b}@example.com
syn cluster arrayMode
      \ contains=@dqMode,@splice,@strings,backslashQuoted,yshComment

" TODO: commandMode can also have operators like ; | < <<
syn cluster commandMode
      \ contains=@arrayMode

syn cluster exprMode
      \ contains=@dollarSubInExpr,@splice,@strings,@caret,yshArrayLiteral
