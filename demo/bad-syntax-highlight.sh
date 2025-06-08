#!/usr/bin/env bash
#
# Where does Vim fail to highlight shell correctly?
#
# Usage:
#   demo/bad-syntax-highlight.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

comments() {
  echo yes # comment

  # Vim does wrong highlighting

  echo not#comment

  # hard case
  echo yes;#comment
}

# There is a list of recent bugs in sh.vim
# https://github.com/vim/vim/blob/master/runtime/syntax/sh.vim
#
# Could test emacs and other editors too

multiple-here-docs() {
  # the second here doc isn't right
  diff -u /dev/fd/3 /dev/fd/4 3<<EOF3 4<<EOF4
foo
EOF3
bar
EOF4
}

command-sub-case() {
  # parens aren't right
  echo $(case foo in foo) echo hi ;; esac)

  echo "$(case foo in foo) echo hi ;; esac)"

  # for comparison
  case foo in foo) echo hi ;; esac
}

bad-chars() {
  # the \n should be \\n
  # the \- should be \\-
  echo "hi \n \- \\"  

  # the \n should be \\n
  echo \n \\

  # u03bc should be highlighted
  echo $'hi\n \\ hi mu = \u03bc '
}

not-highlighted() {
  # Why not highlight these?
  echo {a,b}@example.com

  echo {1..3}-{4..5}-{a,b}

  echo *.py ?.[ch] foo.?

  # history
  echo !$
}

my-echo() {
  echo "$@"
}

good() {
  # this is highlighted correctly

  echo "nested ${undef:-"double"} quotes"
  my-echo "${undef:-'single'} quotes"

  echo '\\ ok'

  echo stderr 1>& 2
  my-echo stderr >& 2

  echo multi \
    line \
    string
}

"$@"
