# Open today's log. Pull first (best-effort) so the other machine's entries
# are present before you edit. A failed pull never blocks logging.
today() {
  git -C "$LIFEOPS" pull --ff-only --quiet 2>/dev/null ||
    echo "lo: pull skipped (offline or local commits) — continuing"
  local f
  f="$(_lo_ensure_today)"
  "${EDITOR:-vi}" "$f"
}
