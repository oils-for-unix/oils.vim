Stage 1: Lex Comments and String Literals - `# \ ' "`
=====

(Up: [YSH Syntax Highlighting](algorithms.md))

In this stage, handle:

1. Comments: `# hi`
1. Quotes that are quoted: `\' \"`
1. String Literals 
   - 3 kinds, 5 styles - `r' u' $"`
   - And the corresponding multi-line string literals - `r''' u''' $"""`

The key idea is that once we understand comments and string literals, then we
know that nested delimiters like `() [] {} $() $[]` are **real code**.

## Screenshots

After recognizing comment and strings, you'll have a **nice and usable syntax
highlighter**.  

![Stage 1 Demo](https://pages.oils.pub/oils-vim/screenshots/stage1-demo.png)

But there is a bug with nested double quotes:

![Stage 1 Nested Double Quotes](https://pages.oils.pub/oils-vim/screenshots/stage1-nested-dq.png)

That is, the second double quote should not close the string.  Instead, it
should open a new string:

    echo "hi $[d["key"]]"   # this is wrong
         ^^^^^^^^^   ^^^^

    echo "hi $[d["key"]]"   # this is the inner string
                 ^^^^^

We can fix this with recursion, discussed in [stage 2](stage2.md).

## Files

- [syntax/stage1.vim](../syntax/stage1.vim)
  - [syntax/lib-comment-string.vim](../syntax/lib-comment-string.vim)
- [testdata/minimal.ysh](../testdata/minimal.ysh)

## Tips

Everything in this stage can be expressed with regexes.

(**My favorite regex** is `" ([^"\]|\\.)* "` - it correctly delimits C-style
string literals with backslash escapes.  Related article:
<https://research.swtch.com/pcdata>.)

- Make sure that `echo not#comment` is not a comment.
  - In shell, a comment is a separate "word".
- Note that `r''` and `$""` are synonyms for `''` and `""`.
- Make sure that a `'` closes a raw string, even if there's a `\` before it
  - e.g. `r'C:\Program Files\'`.
- Make sure that `\"` does **not** close a double quoted string - `"\""`
- Likewise for J8 strings -  `b'\''`

## Vim Mechanisms Used

This stage uses Vim regions, with `syn region`.

Why do we skip `\.` and not `\'`?  So that when matching a string `'foo\\'`,
the `\\` is skipped, and we properly see the ending quote.

Note: We haven't included `lexer-modes.vim`, so `contains=@dqMode` is
**ignored**.

## Optional: Make this minimal "flat" highlighter more usable

Here are some minor enhancements that don't affect the overall structure:

1. Keywords like `for func`
1. `$name` and `${name}` (when unquoted, not within double quotes)
1. `@myarray`

See [stage 3](stage3.md) for more ideas.
