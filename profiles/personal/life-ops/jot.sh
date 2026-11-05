# Fast capture: jot "called X about Y — next step Z"
# Inserts under the '## Log' header; falls back to file-append if that header
# is missing, so a capture is never silently lost.
jot() {
  if [ -z "$*" ]; then
    echo "usage: jot <what happened>"
    return 1
  fi
  local file clock entry temp_file insert_entry
  file="$(_lo_ensure_today)"
  clock="$(date +%H:%M)"
  entry="- $clock $*"
  if grep -q '^## Log$' "$file"; then
    temp_file="$(mktemp)"
    # awk: print every line, and the entry once, right after "## Log"
    insert_entry='{print} /^## Log$/ && !inserted {print entry; inserted=1}'
    if awk -v entry="$entry" "$insert_entry" "$file" >"$temp_file"; then
      mv "$temp_file" "$file" || {
        printf '%s\n' "$entry" >>"$file"
        rm -f "$temp_file"
      }
    else
      printf '%s\n' "$entry" >>"$file"
      rm -f "$temp_file"
    fi
  else
    printf '%s\n' "$entry" >>"$file"
  fi
  echo "lo: logged → $(basename "$file")"
}
