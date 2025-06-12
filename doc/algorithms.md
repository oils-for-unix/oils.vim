Three Algorithms for YSH Syntax Highlighting
====

On Zulip, I was asked how to write a syntax highlighter for YSH.  Let's
contrast these ways of doing it:

1. **Coarse Parsing** - Using a regex-based system like Vim or TextMate, it's
   possible to **accurately** recognize YSH "lexer modes", and produce an
   excellent highlighter.
1. **Context-Free Parsing** - The model of Tree-sitter is resilient,
   incremental context-free parsing.
   - YSH should eventually have a Tree-sitter grammar.  But this is tricky
     because context-free grammars are too limited for "real languages".  As
     with most languages (Python, JavaScript, C), recognizing YSH with
     Tree-sitter will require writing **C code** in an external scanner.
1. **Full Parsing** - we could use the YSH parser itself to create a 100%
   accurate syntax highlighter, though it won't be useful in text editors.
   - `ysh --tool syntax-tree myscript.ysh` shows you the syntax tree.

The idea is that different tools have different computational models, so we
have to express YSH syntax within those limits.

## Background: YSH Syntax Has Lexer Modes

YSH syntax is derived from Unix shell syntax, which means that it has [lexer
modes](https://www.oilshell.org/blog/2017/12/17.html).  The modes are roughly:

1. Commands - `echo hi`
1. Double-Quoted Strings - `echo "sum = $[x + 42], today is $(date)"`
1. Expressions - `var x = 42 + a[i]`

This makes YSH different than C or Java, but the same is true for Python and
JavaScript.  They grew more shell-like when they added string interpolation, in
the 2010's:

    console.log(`sum = ${x + 42}`)   // JavaScript    

    print(f'sum = {x + 42}')         # Python

(See [demo/nested.py](../demo/nested.py) and
[demo/nested.js](../demo/nested.js).)

## Algorithm 1: Coarse Parsing - Vim, TextMate

With coarse parsing, we break the problem down into **3 steps**.  Refer to
these docs with **screenshots** for details:

- [Stage 1: Lex Comments and String Literals - `# \ ' "`](stage1.md)
- [Stage 2: Correctly Switch Between Three Lexer Modes - `\ () [] $ @ =`](stage2.md)
- [Stage 3: Recognize the Language Within Each Mode - `and or`](stage3.md)

Coarse parsing is roughly equivalent to identifying these features:

    # comments

    r'    u'    $"         # string literals
    r'''  u'''  $"""       # multi-line literals

    ()    []    ()         # balanced pairs

    $()   $[]  ${}         # sigil pairs
    @()   @[]
    ^()   ^[]       ^""

    const      var         # keywords that take expressions
    setvar     setglobal
    call       =          
    proc       func        # keywords with signatures

Here are the 3 stages, side-by-side.  The first stage is minimal; the second
stage recognizes lexer modes (e.g. commands vs. expressions); and the third
fills in details.

![Stages of Coarse Parsing](https://pages.oils.pub/oils-vim/screenshots/side-by-side.png)

The coarse parsing approach should work with:

1. Vim
1. TextMate (used by VSCode)
1. SublimeText (more powerful than TextMate)
1. Emacs
   - I'm not sure if `font-lock` can do it, but Emacs also supports arbitrary
     Lisp code.

It's important to realize that "coarse" does **not** mean "incorrect"!  Coarse
parsing can actually be **more correct** than full parsing.  Look at all the
bugs fixed in `tree-sitter-bash` for evidence of that:

- <https://github.com/tree-sitter/tree-sitter-bash/commits/master/>

### Highlighting issues

But let's keep track of any correctness issues here:

- stage 1
  - `echo not#comment` vs `echo yes;#comment` (easy to fix)
  - `r''` with word boundary `\<` - TODO: YSH will change.
- stage 2
  - `echo for` - `for` is not a keyword

### Project Idea: Tree-sitter Can Express Stage 1

In Tree-sitter, Stage 2 is **hard** because recursive lexer modes require an
external scanner, written in C.  The C API is unusual because of incremental
lexing and parsing.

On the other hand, stage 1 is **easy** to express.  If you're interested in
Tree-sitter, I recommend starting with stage 1, as "practice".

## Algorithm 2: Context-Free Parsing with Tree-sitter

Even though coarse parsing is easier than context-free parsing, it should give
you much of the YSH knowledge necessary to create a context-free parser.

That said, it may be helpful for us to "recast" YSH syntax as context-free,
with a YSH-only stateful lexer.  (Right now, OSH and YSH share the same
lexer.)

We could create such a YSH-only lexer, and a context-free grammar expressed
with pgen2.  Some notes here:

- [#tools-for-oils > Overview of stateful lexer problem](https://oilshell.zulipchat.com/#narrow/channel/403333-tools-for-oils/topic/Overview.20of.20stateful.20lexer.20problem/with/521811845)
- [#tools-for-oils > YSH Lexer That Can Run By Itself](https://oilshell.zulipchat.com/#narrow/channel/403333-tools-for-oils/topic/YSH.20Lexer.20That.20Can.20Run.20By.20Itself/with/389082925)

Here's how I would start:

1. Create `lex_mode_e.YshDQ`, for double-quoted strings in YSH.
1. Add a string literal grammar in `ysh/grammar.pgen2`
1. Interleave double quoted strings with the expression parser

Then do the same for YSH commands: add a lexer mode, a context-free grammar,
and interleave them with the rest of the language.

## Comparisons

As of 2025-06, our `ysh.vim` plugin is less than 500 lines.

Shell syntax is harder to understand than YSH syntax, but these comparisons might be useful:

- Vim's [sh.vim](https://github.com/vim/vim/blob/master/runtime/syntax/sh.vim) is 1009 lines
- Emac's
  [sh-script.el](https://cgit.git.savannah.gnu.org/cgit/emacs.git/tree/lisp/progmodes/sh-script.el)
  is 3400 lines
- [tree-sitter-bash](https://github.com/tree-sitter/tree-sitter-bash)
  - 1189 lines in `grammar.js`
  - 1217 lines in the external `scanner.c`

Note that some plugins (like Emacs) also do navigation and smart indenting, not
just syntax highlighting.

## Please Ask Questions on Zulip

If you're interested in supporting YSH in a new editor, please ask questions at
`#tools-for-oils` at <https://oilshell.zulipchat.com/>.

We'd like to help create many syntax highlighters!

This set of docs is a good outline, but it may not be complete.

## Appendix

### Structure of the Vim plugin

This command shows an overview:

    ./run.sh count-lines  

Guide:

- `ysh.vim` chooses one of `stage{1,2,3}.vim`
- `stage{1,2,3}.vim` includes other files
- `lexer-modes.vim` is the "high level structure"
- `lib-*.vim` recognize different features
- `testdata/` has examples of each feature
  - We use Vim's `:TOhtml` to publish it to <https://pages.oils.pub/oils-vim/>

Summary:

- Stage 1 - ~60 lines
  - [syntax/stage1.vim](../syntax/stage1.vim)
  - [testdata/minimal.ysh](../testdata/minimal.ysh)
  - Vim features: regex matches, regex regions (without `contains=`)
- Stage 2 - ~260 more lines
  - [syntax/stage2.vim](../syntax/stage2.vim)
  - [syntax/lexer-modes.vim](../syntax/stage2.vim) - declarative definitions of
    YSH lexer modes, with Vim `syn cluster`!  Vim is pretty nice.
  - [testdata/recursive-modes.ysh](../testdata/recursive-modes.ysh)
  - Vim features: `syn cluster`, `contains=@cluster`, `matchgroup=`
  - YSH features: keywords, nested pairs, sigil pairs, `=`
- Stage 3 - ~90 more lines
  - [syntax/stage3.vim](../syntax/stage3.vim)
  - [testdata/details.ysh](../testdata/details.ysh)
  - YSH features: sub and splice, expression keywords, redirects
  - Smart errors: bad backslash escapes

### Notes on YSH Syntax

To change:

- `echo foo = bar` - we might want to make `=` special
- `a = 42` should work, regardless of context
- `$[x] @[array] @array` should be available in expression mode
  - it's ok if `$x` is not there - that is a gentle nudge
- Commands that end with expression: `$(call 42)` and `$(= 42)`
- `--foo=r'raw'` is misleading, and same with `u'' b''`
  - We should fix the YSH quirk.  Then using the `\<` word boundary will not
    misunderstand any correct code.

Note:

- `pp [ch]` vs `pp *.[ch]` - the leading space distinguishes the two

### Links

- [Polyglot Language Understanding](https://github.com/oils-for-unix/oils/wiki/Polyglot-Language-Understanding)
  - Some research for using the coarse parsing technique across multiple languages.
  - One motivation for this is that I found Github's new source browser, with
    semantic navigation, underwhelming.
