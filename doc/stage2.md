Stage 2: Correctly Switch Between Three Lexer Modes - `\ () [] $ @ =`
====

(Up: [YSH Syntax Highlighting](algorithms.md))

This stage is the trickiest, because it involves **recursion**.

In stage 1, we showed the "nested double quotes bug":

![Stage 1 Nested Double Quotes](https://pages.oils.pub/oils-vim/screenshots/stage1-nested-dq.png)

We fix it in this stage, with recursion:

![Stage 2 Nested Double Quotes](https://pages.oils.pub/oils-vim/screenshots/stage2-nested-dq.png)

## Lexer Modes

[A Tour of YSH](https://oils.pub/release/latest/doc/ysh-tour.html) describes
these three mutually recursive **sublanguages**, which are lexed differently.

1. Commands
1. Words/Strings
1. Expressions

Here are some more examples


    echo "dq" $[42 + a[i]]
          ^~   ^~~~~~~~~ expression within command
          |
          + string within command

    var x = "dq" ++ $(echo hi)
             ^~       ^~~~~~~ command within expression
             |
             + string within expression

    echo "dq $(echo hi) $[42 + a[i]]"
               ^~~~~~~    ^~~~~~~~~ expression within string
               |
               + command within string

## Screenshots

![Stage 2 Demo](https://pages.oils.pub/oils-vim/screenshots/stage2-demo.png)

## Files

- [syntax/stage2.vim](../syntax/stage2.vim)
  - [syntax/lexer-modes.vim](../syntax/lexer-modes.vim) - the high-level structure
  - [syntax/lib-command-expr-dq.vim](../syntax/lib-command-expr-dq.vim)
- [testdata/recursive-modes.ysh](../testdata/recursive-modes.ysh)

## Details

### Switching to Expression Mode

- `typedArgs` - `pp (f(x))`
- `lazyTypedArgs` - `pp [f(x)]`
- `rhsExpr` - `var x = f(x)`
- `exprAfterKeyword` - `call f(x)` and `= f(x)`
- `exprSub exprSplice caretExpr` - `$[f(x)] @[f(x)] ^[f(x)]`

### Switching to Command Mode

- `commandSub commandSplice caretCommand` - `$(echo hi) @(echo hi) ^(echo hi)`
- `yshArrayLiteral` - `:| a b |`

### YSH Keywords

We define that the `call` and `=` keywords are followed by expressions.

So we might as well do all the keywords, like `for func`.

### Issues

- `rhsExpr` and `exprAfterKeyword` - they can end after `;` or ` #`
  - `var x = f(42); echo next'
  - `var x = f(42)  # comment
- `nestedParen nestedBracket nestedBrace` - used to match multi-line
  expressions within nested delimiters (a rule borrowed from Python)

# Vim Mechanisms Used

Here, we do it with **Vim regions**.

- TextMate and SublimeText may be similar.
- It's harder in TreeSitter, because stateful / modal lexers require external
  scanners in C, which have an awkward interface constrained by incremental
  parsing.

Vim regions (`syn region`) do all the heavy lifting of lexer modes:

- `contains=` for defining what's valid in each mode.  For example:
  - in DQ strings, `$[sub]` is allowed
  - in commands, `$[sub]` and `@[splice]` are allowed
  - in expressions, `^[lazy]` is allowed (`$[sub]` and `@[splice]` may come later)
- `syn cluster` so you can refer to sets of regions like `@quotedStrings`

Region parameters:

- `nextgroup=` - for `call` and `=` keywords, `func` and `proc`
  - `skipwhite` for `func` and `proc`, to avoid `typedArgs` matching
- `matchgroup=`
  - `matchgroup=Normal` is necessary for nesting of delimiters, like `()` within `$()`
- `end=' #'me=s-2` to say that the end of the match is before the delimiter ` #`, not after
