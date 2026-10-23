# End of day: stage ONLY log/, commit with a content-free message, sync.
eod() {
  local d
  d="$(date +%Y-%m-%d)"

  if [ -z "$(git -C "$LIFEOPS" status --porcelain -- log/)" ]; then
    echo "lo: no log changes to commit"
    return 0
  fi

  git -C "$LIFEOPS" add -- log/ || return 1

  if ! git -C "$LIFEOPS" commit -m "log: $d update"; then
    echo "lo: commit failed — most likely the 1Password SSH signing agent"
    echo "    (signing key in the Development vault / agent.toml). Fix that,"
    echo "    then rerun: eod"
    return 1
  fi

  if ! git -C "$LIFEOPS" pull --rebase --autostash --quiet; then
    echo "lo: pull --rebase stopped — the repo is now MID-REBASE."
    echo "    Inspect:  git -C \"$LIFEOPS\" status"
    echo "    Resolve conflicts, 'git add' them, then:"
    echo "      git -C \"$LIFEOPS\" rebase --continue   (repeat until done)"
    echo "    Or back out entirely:"
    echo "      git -C \"$LIFEOPS\" rebase --abort"
    echo "    Push only AFTER the rebase finishes."
    return 1
  fi

  git -C "$LIFEOPS" push --quiet && echo "lo: pushed log for $d"
}
