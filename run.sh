#!/usr/bin/env bash
#
# Usage:
#   ./run.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

test-files() {
  ### Run testdata
  for f in testdata/*.ysh; do
    echo "=== $f ==="
    ysh $f
    echo
  done
}

show-modes() {
  # summarize
  grep -B 1 'contains=' syntax/stage2-*.vim
}

count-stages() {
  echo 'STAGE 1'
  wc -l syntax/stage1-* syntax/lib-comment-string.vim
  echo

  echo 'STAGE 2'
  wc -l syntax/stage2-* syntax/lib-comment-string.vim
  echo
}

"$@"
