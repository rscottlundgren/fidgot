: "${LIFEOPS:=$HOME/git/github/rscottlundgren/life-ops}"

# --- internal helpers -------------------------------------------------------

_lo_today_path() {
  printf '%s/log/%s/%s/%s.md' \
    "$LIFEOPS" "$(date +%Y)" "$(date +%m)" "$(date +%d)"
}

# Ensure today's file exists (rendered from the template); echo its path.
_lo_ensure_today() {
  local f
  f="$(_lo_today_path)"
  if [ ! -f "$f" ]; then
    mkdir -p "$(dirname "$f")"
    if [ -f "$LIFEOPS/templates/daily.md" ]; then
      sed "s/{{DATE}}/$(date +%Y-%m-%d)/" \
        "$LIFEOPS/templates/daily.md" >"$f"
    else
      printf '# %s\n\n## Log\n' "$(date +%Y-%m-%d)" >"$f"
    fi
  fi
  printf '%s' "$f"
}
