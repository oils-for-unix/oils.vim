YSH Syntax Highlighting Checklist
====

## Stage 1 - Minimal Lexing

In this stage, handle:

1. Keywords like `for func`
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

### Optional Stage 1a

To make the minimal stage 1 more useful, you add support for:

- `$1` and `${12}`, but not `$12`
- `$x` and `${x}` 
  - But not double-quoted `"$foo"` or `"${foo}"`, because that requires
    `contains=`, which not all syntax metalanguages support (e.g. Treesitter)
  - TODO: ysh `${x|html}` `${x .%3d}`
- `@myarray`

## Stage 2 - Mutually Recursive Commands, Strings, and Expressions

TODO

This requires **lexer modes**.

- In Vim, we use "regions".
- TextMate may be similar.
- It's harder in TreeSitter, because stateful / modal lexers require external
  scanners in C, which have an awkward interface constrained by incremental
  parsing.

See:

- [testdata/lexer-modes.ysh](testdata/lexer-modes.ysh)

## Stage 3 - Detailed Highlighting

TODO

- atoms: true false null - only in expressions
  - shell builtins?  not sure if we want that
- numeric constants 42, 99.0, 1.1e-100

Backslashes mean different things in different modes:

- `\;` in the unquoted lexer mode, but not `\n`
- `\$` in double quoted strings, but not `\n`
- `\n` and `\yff` and `\u{3bc}` in J8 strings
  - as well as unquoted in expressions

Expressions:

- `/[a-z]/` in Eggex are somewhat special

Redirects appear in commands, and don't affect lexer modes.  They have their
own little lexical language:

- `echo hi 2> /dev/null`
- `echo hi {left}< left {right}< right`
- `>> <<`
- `<<<`

Commands and YSH array literals `:| a b|`:

- Brace expansion: `{a,b}@example.com`
- Globs: `*.py` and `?.[ch]`

History expansion?

- `!!` and `!$` and ...

## Problems / Syntax to Change?

- `echo foo = bar` - we might want to make `=` special
- `pp [ch]` vs `pp *.[ch]` - is a leading space enough to distinguish the two?

Also fiddly:

- leading space rule for `pp (x)`
- space rule for `= f(x)`
