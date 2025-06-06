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

modes() {
  # summarize
  grep -B 1 'contains=' syntax/stage2-*.vim
}

"$@"
