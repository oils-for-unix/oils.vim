#!/usr/bin/env bash
#
# Usage:
#   ./run.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

test-files() {
  ### Run testdata
  ysh testdata/minimal.ysh
}

"$@"
