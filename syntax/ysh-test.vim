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
