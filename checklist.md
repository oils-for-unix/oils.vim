YSH Syntax Highlighting Checklist
====

## Stage 1 - Minimal Lexing

In this stage, handle:

1. Keywords like `for func`
1. Comments: `# hi`
1. Quotes that are Quoted: `\' \"`
1. String Literals - 3 kinds, 5 styles
   - And the corresponding multi-line string literals

Key idea: once we **understand** comments and string literals, then we know
that nested delimiters like `() [] {} $() $[]` are **real code**.

See:

- [testdata/minimal.ysh](testdata/minimal.ysh)

At the end, you will be left with the NESTED double quotes bug.

TODO: screenshot.

## Stage 2 - Mutually Recursive Commands, Strings, and Expressions

This requires **lexer modes**.

- In Vim, we do it with regions.
- TextMate may be similar.
- It's harder in TreeSitter.

TODO

- [testdata/lexer-modes.ysh](testdata/lexer-modes.ysh)

## Stage 3 - Detailed Highlighting

TODO

- We may want to handle:

- `\n` in expressions
- `\n` in J8 strings
- `/[a-z]/` in Eggex
- `\;` when unquoted
