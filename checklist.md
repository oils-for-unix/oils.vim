YSH Syntax Highlighting Checklist
====

Let's write a YSH syntax highlighter.  We'll break the problem down into **3
steps**, to focus on **correctness**.

## Stage 1 - Lex Comments and String Literals - `# \ ' "`

In this stage, handle:

1. Comments: `# hi`
1. Quotes that are Quoted: `\' \"`
1. String Literals 
   - 3 kinds, 5 styles - `r' u' $"`
   - And the corresponding multi-line string literals - `r''' u''' $"""`

Key idea: once we **understand** comments and string literals, then we know
that nested delimiters like `() [] {} $() $[]` are **real code**.

See:

- [testdata/minimal.ysh](testdata/minimal.ysh)
- [syntax/ysh-minimal.vim](syntax/ysh-minimal.vim)

Install this Vim syntax definition with the instructions in
[README.md](README.md), and see what it looks like:

![YSH Minimal Lexing](https://oils.pub/image-deploy/ysh-minimal-lexing.png)

At the end, you will be left with a **pretty nice syntax highlighter**.  But
there is a bug with nested double quotes:

![Nested Double Quotes Bug](https://oils.pub/image-deploy/nested-double-quotes-bug.png)

That is, the second double quote should not close the string.  It should open a
new string:

    echo "hi $[d["key"]]"   # this is wrong
         ^^^^^^^^^   ^^^^

    echo "hi $[d["key"]]"   # this is the inner string
                 ^^^^^

We can fix this with recursion.

### Tips

Everything in this stage can be expressed with regexes.  **My favorite regex** is
`" ([^"\]|\\.)* "` - it correctly delimits C-style string literals with
backslash escapes.  (Related article: <https://research.swtch.com/pcdata>).

- Make sure that a `'` closes a raw string, even if there's a `\` before it
  - e.g. `r'C:\Program Files\'`.
- Make sure that `\"` does **not** close a double quoted string, and that `\'` does
  not close a J8 string.
  - e.g. `"\""` and `b'\''`
- Make sure that `echo not#comment` is not a comment.
  - In shell, a comment is a separate "word".

### Vim Mechanisms Used

- Regions
  - Why do we skip `\.` and not `\'`?  So that when matching a string
    `'foo\\'`, the `\\` is skipped, and we properly see the ending quote.
- TODO: more

### Optional: Make this minimal "flat" highlighter more usable

Some minor enhancements that don't affect the overall structure:

1. Keywords like `for func` (`ysh-minimal` does this)
1. `$name` and `${name}` (when unquoted, not within double quotes)
1. `@myarray`

See "Stage 3" for more ideas.

## Stage 2 - Correctly Switch Between Three Lexer Modes - `\ $ @ () [] call =`

[A Tour of YSH](https://oils.pub/release/latest/doc/ysh-tour.html) describes
these three mutually recursive **sublanguages**, which are lexed differently.

1. Commands
1. Words/Strings
1. Expressions

It's done with **Vim Regions**.

- In Vim, we use **regions**.
- TextMate and SublimeText may be similar.
- It's harder in TreeSitter, because stateful / modal lexers require external
  scanners in C, which have an awkward interface constrained by incremental
  parsing.

See:

- [testdata/lexer-modes.ysh](testdata/lexer-modes.ysh)

### Switching to Expression Mode

- `typedArgs` - `pp (f(x))`
- `lazyTypedArgs` - `pp [f(x)]`
- `rhsExpr` - `var x = f(x)`
- `exprAfterKeyword` - `call f(x)` and `= f(x)`
- `exprSub exprSplice caretExpr` - `$[f(x)] @[f(x)] ^[f(x)]`

### Switching to Command Mode

- `commandSub commandSplice caretCommand` - `$(echo hi) @(echo hi) ^(echo hi)`
- `yshArrayLiteral` - `:| a b |`

### Var Subs

In YSH, yar subs **non-recursive** leaves.  But we add them here to show off
the DQ-string lexer mode.

- `$1` and `${12}`, but not `$12`
- `$x` and `${x}` 
  - Recognizing double-quoted `"$foo"` or `"${foo}"` requires stage 2, e.g. with Vim
    `contains=`.  Not all syntax metalanguages support lexer modes (e.g.
    Treesitter).
  - TODO: ysh `${x|html}` `${x .%3d}`

### YSH Keywords

We define that the `call` and `=` keywords are followed by expressions.

So we might as well do all the keywords, like `for func`.

### Issues

- `rhsExpr` and `exprAfterKeyword` - they can end after `;` or ` #`
  - `var x = f(42); echo next'
  - `var x = f(42)  # comment
- `nestedParen nestedBracket nestedBrace` - used to match multi-line
  expressions within nested delimiters (a rule borrowed from Python)

### Vim Mechanisms Used

Vim regions (`syn region`) do all the heavy lifting of lexer modes:

- `contains=` for defining what's valid in each mode.  For example:
  - in DQ strings, `$[sub]` is allowed
  - in commands, `$[sub]` and `@[splice]` are allowed
  - in expressions, `^[lazy]` is allowed (`$[sub]` and `@[splice]` may come later)
- `syn cluster` so you can refer to sets of regions like `@quotedStrings`

Region parameters:

- `nextgroup= skipwhite` - for `call` and `=` keywords
- `matchgroup=`
  - `matchgroup=Normal` is necessary for nesting of delimiters, like `()` within `$()`
  - `matchgroup=NONE` for `call` and `=` keywords
- `end=' #'me=s-2` to say that the end of the match is before the delimiter ` #`, not after

## Stage 3 - Recognize Details Within Each Mode

### More on Expressions

- atoms: true false null - only in expressions
  - shell builtins?  not sure if we want that
- numeric constants 42, 99.0, 1.1e-100

An eggex is an expression.

- `/[a-z]/` in Eggex are somewhat special

### Redirects

Redirects appear in commands, and don't affect lexer modes.  They have their
own little lexical language:

- `echo hi 2> /dev/null`
- `echo hi {left}< left {right}< right`
- `>> <<`
- `<<<`

Note that YSH array literals liek `:| a b |` don't have redirects.

### Word Sequence Language

These appear in both commands an array literals:

- Brace expansion: `{a,b}@example.com`
- Globs: `*.py` and `?.[ch]`
- Splice array: `@myarray`

### Word Language

History expansion?

- `!!` and `!$` and ...

### Backslashes mean different things in different modes

- `\;` in the unquoted lexer mode, but not `\n`
- `\$` in double quoted strings, but not `\n`
- `\n` and `\yff` and `\u{3bc}` in J8 strings
  - as well as unquoted in expressions

## TODO

### YSH Syntax to Change?

- `echo foo = bar` - we might want to make `=` special
- `pp [ch]` vs `pp *.[ch]` - is a leading space enough to distinguish the two?

### `ysh.vim` issues

- `{}` is not highlighted the same as `() []`.  This is cosmetic.  The key
  point is that the nesting is correct.
