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
1. Unquoted `$foo`
   - But not `"$foo"` or `${foo}`

Key idea: once we **understand** comments and string literals, then we know
that nested delimiters like `() [] {} $() $[]` are **real code**.

See:

- [testdata/minimal.ysh](testdata/minimal.ysh)

Install this Vim syntax definition with the instructions in
[README.md](README.md), and see what it looks like:

![YSH Minimal Lexing](https://oils.pub/image-deploy/ysh-minimal-lexing.png)

At the end, you will be left with the **nested double quotes bug**:

![Nested Double Quotes Bug](https://oils.pub/image-deploy/nested-double-quotes-bug.png)

That is, the second double quote should not close the string.  It should open a
new string:

    echo "hi $[d["key"]]"
         ^^^^^^^^^   ^^^^

We can fix this with recursion.

### Tips

Everything in this stage can be expressed with regexes.  **My favorite regex** is
`" ([^"\]|\\.)* "` - it correctly delimits C-style string literals with
backslash escapes.  (Related article: <https://research.swtch.com/pcdata>).

- Make sure that a `'` closes a raw string, even if there's a `\` before it:
  `r'C:\Program Files\'`.
- Make sure that `\"` does **not** close a double quoted string, and that `\'` does
  not close a J8 string.
- Make sure that `echo not#comment` is not a comment.  This is a special shell
  rule.

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

We may want to handle:

- `\n` in expressions
- `\n` in J8 strings
- `/[a-z]/` in Eggex
- `\;` when unquoted
