Stage 4: Smart Errors by "Over-Lexing"
====

TODO

```   
var myarray = :| hi ; > |  # no operator chars

var x = u'foo \yff'        # no byte escapes

var x = b'invalid \z'      # no \z

echo \n    # should be n

echo "\n"  # should be "\\n"
```   
