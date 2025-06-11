source <sfile>:h/lib-comment-string.vim
source <sfile>:h/lib-command-expr-dq.vim

redir > _tmp/ysh-test.log

" String Interpolation only works on RHS
let x = "world"
let greeting= $"hi {x}"
echo $"{greeting}"

" Things to test
" - anchor to beginning of line?

call assert_equal(0, match('= 42', equalsRegex))
call assert_equal(0, match('  = 42', equalsRegex))
call assert_equal(-1, match('foo  = 42', equalsRegex))

call assert_equal(0, match('call', callRegex))
call assert_equal(0, match('call ', callRegex))
call assert_equal(2, match('  call ', callRegex))

call assert_equal(2, match(' ;call ', callRegex))
call assert_equal(3, match(' ; call ', callRegex))

call assert_equal(3, match('|| call ', callRegex))
call assert_equal(3, match('&& call ', callRegex))

call assert_equal(-1, match('decall', callRegex))
call assert_equal(-1, match('calling', callRegex))

let x = 0
if x
  echo 'TESTING'
  call assert_equal(0, match('call', '\vcall'))
  call assert_equal(0, match('a ', '\v^\s*(a|b)'))
  call assert_equal(0, match('b', '\v^(a|b)'))
  call assert_equal(-1, match('c', '\v(a|b)'))

  let callRegex2 = '\v^\s*call'
  call assert_equal(0, match('call 42', callRegex2))

  " WTF \> breaks here?  \v and \> is problematic?
  let callRegex2 = '\v(^|;)\s*call'
  call assert_equal(0, match('; call 42', callRegex2))
endif

let callRegex2 = '\(^\|;\)\s*call\>'
call assert_equal(0, match('; call 42', callRegex2))

" Check for failures
if len(v:errors) > 0
  echo 'Tests failed:'
  for error in v:errors
    echo '  ' . error
  endfor
  " exit
  cquit 1
else
  echo '  OK ysh-test'
endif

echo ''

redir END
