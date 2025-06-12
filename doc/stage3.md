Stage 3: Recgonize the Language Within Each Mode - `and \n`
====

(Up: [YSH Syntax Highlighting](algorithms.md))

In [stage 2](stage2.md), we recognized three mutually recursive lexer modes.
command, expression, and string.

Now we can recognize expressions, we can recognize keywords inside expressions:

    echo and                # based on context, this is not a keyword
    var x = true and false  # it's a keyword!

We can also disambigate the different meanings of `\n`:

    echo \n     # syntax error
    echo "\n"   # syntax error

    echo u'\n'  # newline
    var x = \n  # newline

## Screenshots

![Stage 3 Demo](https://pages.oils.pub/oils-vim/screenshots/stage3-demo.png)

## Files

- [syntax/stage3.vim](../syntax/stage3.vim)
  - [syntax/lib-details.vim](../syntax/lib-details.vim)
- [testdata/details.ysh](../testdata/details.ysh) - This file has **examples**
  of what we want to recognize.
  - The highlighted version is published to <https://pages.oils.pub/oils-vim/>.

## Vim Mechanisms Used

If a regex starts with `\v`, it's parsed in "very magic" mode.  This makes the
syntax more like PCRE or POSIX ERE.

For example, `a{3,4}` is repetition, and `\{\}` are literal braces, not the
other way around!

## Notes

### Var Subs and Var Splice

In YSH, var subs are **non-recursive** leaves. 

- `$1` and `${12}`, but not `$12`
- `$x` and `${x}`
  - may occur in commands, or double-quoted strings
- TODO: ysh `${x|html}` `${x .%3d}`
- `echo @myarray`

## TODO

We can recognize more of YSH in stage 3.

### Multi-Line Commands

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

(In contrast, balanced delimiters `() [] {}` in expressions allow them to span
multiple lines.)

### More on Expressions

- Atoms
  - `true false null` - only in expressions
- Numeric constants 42, 99.0, 1.1e-100
- Builtin functions like `len(x)`?

An eggex is an expression:

- `/[a-z]/` in Eggex are somewhat special

### Redirects

Redirects appear in commands, and don't affect the lexer mode.  They have their
own little lexical language:

    echo hi 2> /dev/null
    echo hi {left}< left {right}< right

    echo append >> myfile.txt

    cat <<< '''
      multi-
      line
      '''

Note: YSH array literals like `:| my-array echo hi |` don't have redirects.

### Word Language

- `~/src` and `~bob/src`
- History expansion?  `!!` and `!$` and ...

### Word Sequence Language

These constructs appear in both commands and array literals:

- Brace expansion: `{a,b}@example.com`
- Globs: `*.py` and `?.[ch]`
- Splice array: `@myarray`

### Builtin Procs


Examples:

    echo hi
    command echo hi
    command -p echo hi

Notes:

- We can export a list of YSH builtins from the Oils binary
  - leaving out legacy like `. : [ alias unalias`
- Color them differently than keywords?

## Smart Errors by "Over-Lexing" 

### Backslashes mean different things in different modes - `\n`

- `\;` in the unquoted lexer mode, but not `\n`
- `\$` in double quoted strings, but not `\n`
- `\n` and `\yff` and `\u{3bc}` in J8 strings
  - as well as unquoted in expressions

```   
var myarray = :| hi ; > |  # no operator chars

var x = u'foo \yff'        # no byte escapes

var x = b'invalid \z'      # no \z

echo \n    # should be n

echo "\n"  # should be "\\n"
```   

### Sigil Pairs - `$ @`

- `parse_dollar` - `echo $.` should be an error
- Then `@.` should also be an error

### Arrays vs. Commands

Could highlight these as errors:

    var array = :| hi < ; |

## Conclusion

Let me know if you got this far!  And feel free to ask questions on Zulip:

- <https://oilshell.zulipchat.com/>

