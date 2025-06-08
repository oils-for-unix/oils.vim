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
    lib-command-expr-dq.vim
  echo

  echo 'STAGE 3'
  wc -l stage3-* \
    lib-details.vim 
  echo

  if false; then
    echo 'ALL'
    wc -l *.vim
    echo
  fi

  popd
}

write-html-stage() {
  local stage=${1:-3}

  local dir="_tmp/stage${stage}"

  mkdir -p $dir

  for f in testdata/*.ysh; do
    YSH_SYNTAX_STAGE=$stage vim -c 'TOhtml' -c 'wqa' $f
    echo status=$?
  done

  mv -v testdata/*.html $dir

  ls -l $dir
}

write-html() {
  rm -rf _tmp/
  for stage in 1 2 3; do
    write-html-stage $stage
  done
}

"$@"
