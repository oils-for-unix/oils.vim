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
    # 'demo' arg for screenshot.ysh
    ysh $f demo
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

readonly HTML_DIR=_tmp/oils-vim

write-html-stage() {
  local stage=${1:-3}

  local dir="$HTML_DIR/stage${stage}"

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

write-index() {
  tree -H './' -T 'Files in oils-vim/' --charset=ascii $HTML_DIR \
    > $HTML_DIR/index.html
}

deploy-html() {
  write-index

  local dest=../pages/oils-vim/
  mkdir -p $dest
  cp -v -r --no-target-directory $HTML_DIR $dest
}

run-test() {
  local log_file=$1
  local vim_file=$2

  rm -v -f "$log_file"

  #set -x

  set +o errexit
  vim -c "source $vim_file" -c 'qa!'
  local status=$?
  set -o errexit

  cat "$log_file"
  echo
  echo status=$status
}

regexp-test-vim() {
  run-test _tmp/regexp-test.log demo/regexp-test.vim
}

ysh-test-vim() {
  run-test _tmp/ysh-test.log syntax/ysh-test.vim
}


"$@"
