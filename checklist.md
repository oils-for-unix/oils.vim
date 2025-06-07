Two Algorithms for YSH Syntax Highlighting
====

I started this doc after writing a Vim syntax highlighter for YSH.  In Vim, we
do what I call **"coarse parsing"**.

We also want a Tree-sitter highlighter.  Tree-sitter has the philosophy of
**full parsing**, so I also outline how we can support this style.

---

But it's important to realize that `coarse != incorrect`!

Coarse parsing can actually be **more correct** than full parsing.  Look at the
changelog of `tree-sitter-bash` for evidence of that:

- <https://github.com/tree-sitter/tree-sitter-bash/commits/master/>

## Background: YSH Syntax Has Lexer Modes

YSH syntax is derived from Unix shell, which means that it has [lexer
modes](https://www.oilshell.org/blog/2017/12/17.html).  The modes are roughly:

1. Commands - `echo hi`
1. Double-Quoted Strings - `echo "sum = $[x + 42], today is $(date)"`
1. Expressions - `var x = 42 + a[i]`

This makes YSH different than C or Java.

But Python and JavaScript are also different than C and Java.  They grew more
shell-like when they added string interpolation, in the 2010's:

    console.log(`sum = ${x + 42}`)   // JavaScript    

    print(f'sum = {x + 42}')         # Python

## Algorithm 1: Coarse Parsing - Vim, TextMate

With coarse parsing, we break the problem down into **4 steps**.  Refer to
these docs for details:

- [Stage 1: Lex Comments and String Literals - `# \ ' "`](stage1-checklist.md)
  - [syntax/stage1-minimal.vim](syntax/stage1-minimal.vim)
  - [testdata/minimal.ysh](testdata/minimal.ysh)
  - Vim features: regex matches, regex regions (without `contains=`)
- [Stage 2: Correctly Switch Between Three Lexer Modes - `\ () [] $ @ =`](stage2-checklist.md)
  - [syntax/stage2-recursive-modes.vim](stage2-recursive-modes.vim)
  - [testdata/recursive-modes.ysh](testdata/recursive-modes.ysh)
  - Vim features: `syn cluster`, `contains=@cluster`, `matchgroup=`
  - YSH features: nested pairs, sigil pairs
  - Highlighting issues: `echo for` - `for` is not a keyword
- [Stage 3: Recognize Details Within Each Mode](stage3-checklist.md)
  - YSH features: expression keywords, redirects
- [Stage 4: Smart Errors by "Over-Lexing"](stage4-checklist.md)

This approach should work with:

1. Vim
1. TextMate (used by VSCode)
1. SublimeText (more powerful than TextMate)
1. Emacs
   - I'm not sure if `font-lock` can do it, but Emacs also supports arbitrary
     Lisp code.

### Tree-sitter Can Express Stage 1

Stage 2 is **hard** because recursive lexer modes require an **external**
Tree-sitter scanner, written in C.  The C API is unusual because it must
support incremental lexing and parsing.

But stage 1 is **easy** to express in Tree-sitter.  If you're interested in
Tree-sitter, I recommend **starting** with stage 1.

Caveat: Emacs-like navigation and indentation requires stage 2.

## Algorithm 2: Full Parsing - TreeSitter

TODO

Notes:

- Stateful YSH Lexer That Runs By Itself

Approach:

1. Create `lex_mode_e.YshDQ`
1. Add a string literal grammar in `ysh/grammar.pgen2`
1. Interleave it with the expression parser

Then do the same for YSH commands - add lexer mode, and a parser, and
interleave them.

## Notes

- `pp [ch]` vs `pp *.[ch]` - the leading space distinguishes the two?

### YSH Syntax to Change?

- `echo foo = bar` - we might want to make `=` special
- `a = 42` should work, regardless of context
- `$[x] @[array] @array` should be available in expression mode
  - it's ok if `$x` is not there - that is a gentle nudge
- Commands that end with expression: `$(call 42)` and `$(= 42)`
- `--foo=r'raw'` is misleading, and same with `u'' b''`
  - we are also highlighting it in a misleading way now, since `\<` marks a
    word boundary
