Stage 3: Recgonize Details Within Each Mode - `and or`
====

### Substitutions and Splicing

- [lib-sub-splice.vim](syntax/lib-sub-splice.vim)

Var S

### Multi-Line

These constructs have no effect on the command lexer mode.

```
echo \
    multi- \
    line # shell style

... echo
    multi-
    line
    ;  # YSH style
```

In contrast, balanced delimiters `() [] {}` in expressions allow them to span
multiple lines.

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

Note that YSH array literals like `:| a b |` don't have redirects.

### Word Sequence Language

These appear in both commands an array literals:

- Brace expansion: `{a,b}@example.com`
- Globs: `*.py` and `?.[ch]`
- Splice array: `@myarray`

### Word Language

- `~/src` and `~bob/src`
- History expansion?  `!!` and `!$` and ...

### Builtin Procs

- Export a list of YSH builtins from the Oils binary
  - leaving out legacy like `. : [ alias unalias`
- Color them differently
- I wonder if the second and third word can be highlighted, e.g.
  - command echo; command -v echo
  - maybe we just treat them as keywords
