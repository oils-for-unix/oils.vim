Stage 1: Lex Comments and String Literals - `# \ ' "`
=====

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
- [syntax/stage1-minimal.vim](syntax/stage1-minimal.vim)

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



