#!/usr/bin/env bash
# Run fidgot's tests. See README.md in this folder.
#
# Usage: tests/run.sh [--slow] [go test flags]
#   --slow   also run the language-server tests (the "slow" build tag)
#   Anything else goes to `go test`, e.g. -v or -run Install.
#
# Afterwards, warns (never fails) if the common Brewfile isn't fully
# installed: that's this machine's state, not the repo's.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

tags=()
args=()
for arg in "$@"; do
  case "$arg" in
  --slow) tags=(-tags slow) ;;
  -h | --help)
    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *) args+=("$arg") ;;
  esac
done

status=0
# -count=1: the results depend on the machine, so never reuse cached ones
go test -count=1 ${tags[@]+"${tags[@]}"} ${args[@]+"${args[@]}"} ./... || status=$?

if command -v brew >/dev/null; then
  if ! missing="$(brew bundle check --verbose --file ../profiles/common/Brewfile 2>&1)"; then
    echo
    echo "warning: the common Brewfile isn't fully installed (not a test failure):"
    grep '→' <<<"$missing" | sed 's/^/  /' || true
  fi
fi

exit "$status"
