# Coding agents

`setup.sh` sets up the coding-agent config (Claude Code instructions, settings,
skills, hooks and the handoff helper) from two private repos:

- `rscottlundgren/agent-config`: the config and its installer, `agent-install`.
- `rscottlundgren/context`: where handoffs are written (personal profile).

```sh
profiles/common/agents/setup.sh --profile personal --dry-run   # preview
profiles/common/agents/setup.sh --profile personal
```

For a work machine, pass that machine's profile name instead of `personal`. A
work profile's context repo is set up as agent-config's own work-machine docs
describe, not by this script.

What it does, skipping anything already in place:

1. Clones agent-config into `~/git/github/rscottlundgren/agent-config`, or
   fast-forwards an existing clone (local changes are left alone).
2. Runs `agent-install --profile <profile> --backup`, which links the files into
   `~/.claude`, installs the handoff helper with `go install` and seeds
   `~/.config/agent-config/handoff.json`; then `agent-install --check`. Real
   files in the way are renamed `*.bak-<timestamp>`.
3. Personal profile: clones (or fast-forwards) the context repo next to it.

Needs `git` and `go` (both in the common Brewfile) and, to clone the private
repos over HTTPS, a GitHub sign-in: `gh auth login`. The script stops with that
hint if you aren't signed in.
