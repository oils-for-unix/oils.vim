YSH Syntax Highlighting - Overview
====

Let's write a YSH syntax highlighter.  We'll break the problem down into **3
steps**, to focus on **correctness**.

## Stages

- [Stage 1: Lex Comments and String Literals](stage1-checklist.md)
- [Stage 2: Correctly Switch Between Three Lexer Modes](stage2-checklist.md)
  - modes: command, expression, double quote
  - features: nested pairs, sigil pairs
- [Stage 3: Highlight Details Within Each Mode](stage3-checklist.md)

## Notes

- `pp [ch]` vs `pp *.[ch]` - the leading space distinguishes the two?

## TODO

### YSH Syntax to Change?

- `echo foo = bar` - we might want to make `=` special
- `a = 42` should work, regardless of context
- `$[x] @[array] @array` should be available in expression mode
  - it's ok if `$x` is not there - that is a gentle nudge
- Commands that end with expression: `$(call 42)` and `$(= 42)`
- `--foo=r'raw'` is misleading, and same with `u'' b''`
  - we are also highlighting it in a misleading way now, since `\<` marks a
    word boundary

