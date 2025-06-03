
## Notes

- The (nascent) "micro syntax" style supports only
  - comments
  - string literals

But maybe that is too minimal.  I also like to highlight:

- `\n` within string literals (and outside perhaps)
- Within double quoted string literals:
  - `$myvar`
  - `${myvar}`
  - `$[myvar]`

### Command vs. Expression Mode

Users do have problems with this distinction.

I wonder if syntax highlighting can help.  Here are the places it changes in YSH

    var y = 42 + f(expr)
    var y = ^[42 + f(expr)]
    # const, setvar, setglobal

    = 42 + f(expr)
    call f(expr)

    echo $[42 + f(expr)]
    echo @[42 + f(expr)]

    pp (42 + expr)
    pp [42 + expr]

We also have:

    proc p (; x, y) { ...

    func f (x, y) { ...

## Strategy for ysh-recursive

Command mode -> Expression

    var y = f(42)
    = f(42)
    call f(42)
    pp ('hi')
    pp ['hi']              

    echo ls --flag=$[x + 1]  
    echo @[glob('*.py')]

Command mode -> Double quoted

    echo "hi $x"
    echo $"explicit $x"

Expression mode -> Command

    = :| foo.txt *.py |   # note: no redirects here though
    = $(echo command sub)
    = @(echo spliced command sub)
    = ^(echo unevaluated)

Expression mode -> Double Quoted

    = "hi $x"
    = $"explicit $x"
    = ^"unevaluated $x"

Double-Quoted mode ->

    echo "greeting = $(echo hi)"  # Command
    echo "sum = $[x + y]"         # Expression

---

Inconsequential sigil pairs:

    myproc { echo block }

    # never changes the mode, although could be highlighted
    diff <(sort left.txt) <(sort right.txt) 

    var x = ^[42 + i]  # never changes the mode
