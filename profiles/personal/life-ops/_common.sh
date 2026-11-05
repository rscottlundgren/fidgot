: "${LIFEOPS:=$HOME/git/github/rscottlundgren/life-ops}"

# --- internal helpers -------------------------------------------------------

_lo_today_path() {
  printf '%s/log/%s/%s/%s.md' \
    "$LIFEOPS" "$(date +%Y)" "$(date +%m)" "$(date +%d)"
}

# Ensure today's file exists (rendered from the template); echo its path.
_lo_ensure_today() {
  local file
  file="$(_lo_today_path)"
  if [ ! -f "$file" ]; then
    mkdir -p "$(dirname "$file")"
    if [ -f "$LIFEOPS/templates/daily.md" ]; then
      sed "s/{{DATE}}/$(date +%Y-%m-%d)/" \
        "$LIFEOPS/templates/daily.md" >"$file"
    else
      printf '# %s\n\n## Log\n' "$(date +%Y-%m-%d)" >"$file"
    fi
  fi
  printf '%s' "$file"
}
