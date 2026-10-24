#!/usr/bin/env bash
# Set up the personal tools on this machine: clone (or update) the private
# rscottlundgren/fidgot-personal repo and go install its Go tools. Personal
# machine only; install.sh never runs it on a work profile. Safe to rerun.
# See README.md in this folder.
#
# Usage: setup.sh [--dry-run]

set -euo pipefail

dry_run=false
while [ $# -gt 0 ]; do
  case "$1" in
  --dry-run)
    dry_run=true
    shift
    ;;
  -h | --help)
    sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2
    ;;
  esac
done

# Where the personal account's repos live (the git identity is picked by this
# folder; see profiles/common/git). Overridable for testing.
base="${FIDGOT_REPOS_DIR:-$HOME/git/github/rscottlundgren}"
remote_base="${FIDGOT_REMOTE_BASE:-https://github.com/rscottlundgren}"

say() { printf '==> %s\n' "$*"; }
run() {
  if $dry_run; then
    printf '    would run: %s\n' "$*"
  else
    "$@"
  fi
}

need() {
  command -v "$1" >/dev/null || {
    echo "missing: $1 ($2)" >&2
    exit 1
  }
}
need git "brew bundle install --file profiles/common/Brewfile"
need go "brew bundle install --file profiles/common/Brewfile"

# Clone a repo if it's missing; otherwise fast-forward it. Never touches local
# changes: a pull that can't fast-forward stops with git's message. (Same as
# profiles/common/agents/setup.sh.)
clone_or_update() {
  local name="$1" dir="$base/$1"
  if [ -d "$dir/.git" ]; then
    say "$name: updating ($dir)"
    run git -C "$dir" pull --ff-only --quiet
  else
    # The repo is private; over HTTPS, git authenticates through gh
    if [[ "$remote_base" == https://github.com/* ]] && ! gh auth status >/dev/null 2>&1; then
      echo "$name is private: sign in first with \`gh auth login\` (git uses gh for GitHub over HTTPS)" >&2
      exit 1
    fi
    say "$name: cloning into $dir"
    run mkdir -p "$base"
    run git clone --quiet "$remote_base/$name.git" "$dir"
  fi
}

clone_or_update fidgot-personal

personal="$base/fidgot-personal"
if [ -d "$personal" ]; then
  # Builds every Go tool in the repo into ~/go/bin (on PATH via zprofile)
  say "go install ./... (fidgot-personal)"
  (cd "$personal" && run go install ./...)
else
  say "go install: skipped (fidgot-personal isn't cloned yet)"
fi

# The tools keep personal data outside the repo; the repo's own check.sh says
# what's still missing on this machine (read-only, so it runs in a dry run too)
if [ -x "$personal/check.sh" ]; then
  say "check.sh (fidgot-personal)"
  "$personal/check.sh"
else
  say "check.sh: skipped (fidgot-personal isn't cloned yet)"
fi

say "done"
