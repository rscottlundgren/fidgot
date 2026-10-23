# life-ops

Shell functions for the private `life-ops` repo (goals and a dated daily log),
for the personal machine only:

| File         | What                                                                                                      |
| ------------ | --------------------------------------------------------------------------------------------------------- |
| `today.sh`   | `today`: pull (best effort), then open today's log, creating it from the template                         |
| `jot.sh`     | `jot "…"`: add a timestamped line under today's `## Log` heading                                          |
| `eod.sh`     | `eod`: end of day; commit only `log/` with a content-free message, then sync                              |
| `_common.sh` | Helpers the functions share                                                                               |
| `_guard.sh`  | Succeeds only where the life-ops repo exists (`$LIFEOPS`, default `~/git/github/rscottlundgren/life-ops`) |

Nothing loads these automatically yet: the tracked zsh config doesn't source
them. To use them on the personal machine, source them from `~/.zshrc.local`:

```sh
lifeops="$HOME/git/github/rscottlundgren/fidgot/profiles/personal/life-ops"
if source "$lifeops/_guard.sh"; then
  for f in _common today jot eod; do source "$lifeops/$f.sh"; done
fi
```

The capture command is `jot` rather than `log` so it doesn't shadow macOS's
`log` command (system logs).
