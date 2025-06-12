Stage 1: Lex Comments and String Literals - `# \ ' "`
=====

(Up: [YSH Syntax Highlighting](algorithms.md))

In this stage, handle:

1. Comments: `# hi`
1. Quotes that are quoted: `\' \"`
1. String Literals 
   - 3 kinds, 6 styles - `r' u' $"`
   - And the corresponding multi-line string literals - `r''' u''' $"""`

The key idea is that once we understand comments and string literals, then we
know that nested delimiters like `() [] {} $() $[]` are **real code**.

## Screenshots

After recognizing comment and strings, you'll have a minimal, but **usable**
syntax highlighter.

![Stage 1 Demo](https://pages.oils.pub/oils-vim/screenshots/stage1-demo.png)

But there is a bug with nested double quotes:

![Stage 1 Nested Double Quotes](https://pages.oils.pub/oils-vim/screenshots/stage1-nested-dq.png)

That is, the second double quote should not close the string.  Instead, it
should open a new string:

    echo "hi $[d["key"]]"   # this is wrong
         ^^^^^^^^^   ^^^^

    echo "hi $[d["key"]]"   # this is the inner string
                 ^^^^^

We can fix this with **recursion**, discussed in [stage 2](stage2.md).

## Files

- [syntax/stage1.vim](../syntax/stage1.vim)
  - [syntax/lib-comment-string.vim](../syntax/lib-comment-string.vim)
- [testdata/minimal.ysh](../testdata/minimal.ysh)

## Tips

- Make sure that `echo not#comment` is not a comment.
  - In shell, a comment is a separate "word".

Strings:

- Note that `r''` and `$""` are synonyms for `''` and `""`.
- Make sure that a `'` closes a raw string, even if there's a `\` before it
  - e.g. `r'C:\Program Files\'`.
- Make sure that `\"` does **not** close a double quoted string - `"\""`
- Likewise for J8 strings -  `b'\''`

Recognizing strings with Vim regions:

- Why do we skip `\.` and not `\'`?  So that when matching a string `'foo\\'`,
  the `\\` is skipped, and we properly see the ending quote.

Note that everything in this stage can be expressed with regexes.

(**My favorite regex** is `" ([^"\]|\\.)* "` - it correctly delimits C-style
string literals with backslash escapes.  Related article:
<https://research.swtch.com/pcdata>.)


## Vim Mechanisms Used

This stage uses Vim regions, with `syn region`.

Note: We haven't included `lexer-modes.vim`, so `contains=@dqMode` is
**ignored**.

## Optional: Make this minimal highlighter more usable

If it's hard to recognize lexer modes with your tool (e.g. Tree-sitter), you
can skip stage 2, and add features to this minimal syntax highlighter.

These features are "non-recursive", and can be added without affecting the
overall structure:

1. Keywords like `for func`
1. Substitution - `$name` and `${name}`
   - in commands and in double quotes, but not in single quotes
1. Splicing - `@myarray`
1. Redirect operators - `ls 2> /dev/null`

See [stage 3](stage3.md) for features that don't require recursion.

Otherwise, move on to [stage 2](stage2.md), where we recognize the core of YSH:
commands, expressions, and strings.



