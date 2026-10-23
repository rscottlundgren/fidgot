# Fast capture: log "called X about Y — next step Z"
# Inserts under the '## Log' header; falls back to file-append if that header
# is missing, so a capture is never silently lost.
log() {
  if [ -z "$*" ]; then
    echo "usage: log <what happened>"
    return 1
  fi
  local f ts entry tmp
  f="$(_lo_ensure_today)"
  ts="$(date +%H:%M)"
  entry="- $ts $*"
  if grep -q '^## Log$' "$f"; then
    tmp="$(mktemp)"
    if awk -v e="$entry" '{print} /^## Log$/ && !d {print e; d=1}' "$f" >"$tmp"; then
      mv "$tmp" "$f" || {
        printf '%s\n' "$entry" >>"$f"
        rm -f "$tmp"
      }
    else
      printf '%s\n' "$entry" >>"$f"
      rm -f "$tmp"
    fi
  else
    printf '%s\n' "$entry" >>"$f"
  fi
  echo "lo: logged → $(basename "$f")"
}
