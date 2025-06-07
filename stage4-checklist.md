Stage 4: Smart Errors by "Over-Lexing" - `\n`
====


## Backslashes mean different things in different modes

- `\;` in the unquoted lexer mode, but not `\n`
- `\$` in double quoted strings, but not `\n`
- `\n` and `\yff` and `\u{3bc}` in J8 strings
  - as well as unquoted in expressions

TODO

```   
var myarray = :| hi ; > |  # no operator chars

var x = u'foo \yff'        # no byte escapes

var x = b'invalid \z'      # no \z

echo \n    # should be n

echo "\n"  # should be "\\n"
```   

