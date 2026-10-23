#!/usr/bin/env bash
# Set up the coding-agent config on this machine: clone (or update)
# rscottlundgren/agent-config, run its installer for a profile, and on the
# personal profile clone the context repo that handoffs are written to.
# Safe to rerun. See README.md in this folder.
#
# Usage: setup.sh --profile <personal|work-profile-name> [--dry-run]

set -euo pipefail

profile=""
dry_run=false
while [ $# -gt 0 ]; do
  case "$1" in
  --profile)
    profile="${2:-}"
    shift $(($# > 1 ? 2 : 1)) # with no value, fall through to the usage message
    ;;
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
[ -n "$profile" ] || {
  echo "usage: $0 --profile <name> [--dry-run]" >&2
  exit 2
}

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
# changes: a pull that can't fast-forward stops with git's message.
clone_or_update() {
  local name="$1" dir="$base/$1"
  if [ -d "$dir/.git" ]; then
    say "$name: updating ($dir)"
    run git -C "$dir" pull --ff-only --quiet
  else
    # The repos are private; over HTTPS, git authenticates through gh
    if [[ "$remote_base" == https://github.com/* ]] && ! gh auth status >/dev/null 2>&1; then
      echo "$name is private: sign in first with \`gh auth login\` (git uses gh for GitHub over HTTPS)" >&2
      exit 1
    fi
    say "$name: cloning into $dir"
    run mkdir -p "$base"
    run git clone --quiet "$remote_base/$name.git" "$dir"
  fi
}

clone_or_update agent-config

agent_config="$base/agent-config"
install() { (cd "$agent_config" && go run ./cmd/agent-install --profile "$profile" "$@"); }
if $dry_run && [ ! -d "$agent_config" ]; then
  say "agent-install: skipped (agent-config isn't cloned yet)"
elif $dry_run; then
  say "agent-install --profile $profile --dry-run"
  install --dry-run
else
  say "agent-install --profile $profile --backup"
  install --backup
  say "agent-install --check"
  (cd "$agent_config" && go run ./cmd/agent-install --check)
fi

# Personal handoffs go to the personal context repo. A work profile's context
# repo is set up as agent-config's own work-machine docs describe.
if [ "$profile" = personal ]; then
  clone_or_update context
fi

say "done"
