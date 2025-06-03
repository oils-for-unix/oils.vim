#!/usr/bin/env bash
#
# Usage:
#   ./run.sh <function name>

set -o nounset
set -o pipefail
set -o errexit

make-links() {
  ln -s ../oils/doc/syntax/*.ysh .
}

"$@"
