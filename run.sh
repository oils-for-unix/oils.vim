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
  pushd syntax

  echo 'STAGE 1'
  wc -l stage1-* lib-comment-string.vim
  echo

  echo 'STAGE 2'
  wc -l stage2-* \
    lib-vim-clusters.vim \
    lib-comment-string.vim \
    lib-command-expr-dq.vim
  echo

  echo 'STAGE 3'
  wc -l stage3-* \
    lib-vim-clusters.vim \
    lib-comment-string.vim \
    lib-command-expr-dq.vim \
    lib-details.vim 
  echo

  if false; then
    echo 'ALL'
    wc -l *.vim
    echo
  fi

  popd
}

"$@"
