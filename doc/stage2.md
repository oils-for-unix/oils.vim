Stage 2: Correctly Switch Between Three Lexer Modes - `\ () [] $ @ =`
====

(Up: [YSH Syntax Highlighting](algorithms.md))

This stage is the trickiest, because it involves **recursion**.

In [stage 1](stage1.md), we showed the "nested double quotes bug":

![Stage 1 Nested Double Quotes](https://pages.oils.pub/oils-vim/screenshots/stage1-nested-dq.png)

We fix it in this stage, with recursion:

![Stage 2 Nested Double Quotes](https://pages.oils.pub/oils-vim/screenshots/stage2-nested-dq.png)

## Lexer Modes

[A Tour of YSH](https://oils.pub/release/latest/doc/ysh-tour.html) describes
these three mutually recursive **sublanguages**, which are lexed differently.

1. Commands
1. Words/Strings
1. Expressions

Here are some more examples:

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

The nested double quotes example is:

    echo "nested $[mydict["word"]] quotes"
                   ^~~~~~~|    |~ expression within string
                          |++++|  string within expression within string

## Screenshots

![Stage 2 Demo](https://pages.oils.pub/oils-vim/screenshots/stage2-demo.png)

## Files

- [syntax/stage2.vim](../syntax/stage2.vim)
  - [syntax/lexer-modes.vim](../syntax/lexer-modes.vim) - the high-level structure
  - [syntax/lib-command-expr-dq.vim](../syntax/lib-command-expr-dq.vim)
- [testdata/recursive-modes.ysh](../testdata/recursive-modes.ysh) - This file
  has **examples** of what we want to recognize.
  - The highlighted version is published to <https://pages.oils.pub/oils-vim/>.

## Overall Structure in `lexer-modes.vim`

Notice these definitions in `lexer-modes.vim`:

    syn cluster dqMode
          \ contains=varSubName,@dollarSubInExpr

    syn cluster commandMode
          \ ...

    syn cluster exprMode
          \ ...

This is exactly the recursive structure of YSH syntax!  It's defined concisely
with Vim syntax **clusters**, which are named sets of **regions**.

---

We reference the clusters/modes in `lib-command-expr-dq.vim`, e.g. `@exprMode`
and `@commandMode`:

    syn region exprSub matchgroup=sigilPair start='\$\[' end=']'
          \ contains=nestedBracket,@exprMode

    syn region commandSub matchgroup=sigilPair start='\$(' end=')'
          \ contains=nestedParen,@commandMode

This is a nice way of saying that `$[]` contains expressions, and that `$()`
contains commands.

We also include `nestedBracket` and `nestedParen`, so that balanced
delimiters in `$[a[i]]` and `$(json write (x))` are correctly matched.

(This is why it's called *coarse parsing* - within each region, we only match
what we need to!)

## Prerequisites

Now let's look through `lib-command-expr-dq.vim`.

### Backslash-Quoted Operators

In [stage 1](stage1.md), we had to recognize `\'` and `\"` before we recognized `'strings'`.

Likewise, we now have to recognize `\$ \@ \( \) \[ \]` before we recognize
balanced delimiters `() []` and sigil pairs `$() $[]`.

### YSH Keywords

We also have to recognize **keywords** before we recognize expressions.  These
keywords are all treated similarly:

    call =                      # followed by a RHS expression
    var const setvar setglobal  # followed by a LHS and RHS expression
    proc func                   # followed by a name, then a parameter list

## Notes

### Switching to Expression Mode

These rules were the trickiest to develop:

- `exprAfterKeyword` - `call = var const setvar setglobal` and bare assignment
- `spaceParen` - `pp (f(x))` and `if (x) {` and `return (x)` ...
- `lazyTypedArgs` - `pp [f(x)]`
- `exprSub exprSplice caretExpr` - `$[f(x)] @[f(x)] ^[f(x)]`

Parameter lists are similar to expressions:

- `paramList` - `proc my-proc (x, y) {`

Sigil pairs:

- `exprSub exprSplice caretExpr` - `$[f(x)] @[f(x)] ^[f(x)]`

### Switching to Command Mode

- `commandSub commandSplice caretCommand` - `$(echo hi) @(echo hi) ^(echo hi)`
- `yshArrayLiteral` - `:| my-array echo "hi" $[42 + a[i]] |`

### Python-like Rule for Multi-Line Expressions

`nestedParen nestedBracket nestedBrace` are used to match multi-line
expressions within nested delimiters:

    var result = f(x,
                   42 + a[i])

### Subtle Issues

`rhsExpr` and `exprAfterKeyword` end after a newline, `;` or ` #`.  Examples:

    var x = f(42); echo next'
    var x = f(42)  # comment

## Vim Mechanisms Used

### Regions, Clusters, Keywords

Again, we use **Vim regions**, which can be **recursive**.  TextMate and
SublimeText may be similar.

We use these region paramters:

- `contains=` to defines what's valid in each mode.  For example:
  - in DQ strings, `$[sub]` is allowed
  - in commands, `$[sub]` and `@[splice]` are allowed
  - in expressions, `^[lazy]` is allowed (`$[sub]` and `@[splice]` may come later)
- `nextgroup=` - for `call` and `=` keywords, `func` and `proc`
- `matchgroup=`
  - `matchgroup=Normal` is necessary for nesting of delimiters, like `()` within `$()`
- `\zs` in patterns to set the start position
- `end=' #'me=s-2` to say that the end of the match is before the delimiter ` #`, not after
- `skipwhite` for `func` and `proc`, to avoid `spaceParen` matching
  - Note: it seems like we should be able to avoid `skipwhite`?  Another
    "coarse parsing" implementation may illuminate this issue.

We use `syn cluster` to refer to sets of regions like `@dqMode @exprMode
@commandMode`.

### VimScript

We use Vim 8 string interpolation:

    let name = 'world'
    let greeting = $"hello {world}"  # like shell, with {} rather than ${}

We use dynamic evaluation with `execute`.

For example, `execute 'syn match "' . callRegex . '"'` is apparently the only
way to extract `callRegex` into a variable, so it can be tested in
[syntax/ysh-test.vim](../syntax/ysh-test.vim).

## Next

If this all makes sense, move on to [stage 3](stage3.md).
