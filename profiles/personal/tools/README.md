# Personal tools

`setup.sh` installs the tools from
[`rscottlundgren/fidgot-personal`](https://github.com/rscottlundgren/fidgot-personal),
a private repo of scripts and tools meant only for the personal machine.
`install.sh` runs it as its `tools` step on the `personal` profile and never on
a work profile.

```sh
profiles/personal/tools/setup.sh --dry-run   # preview
profiles/personal/tools/setup.sh
```

What it does, skipping anything already in place:

1. Clones fidgot-personal into `~/git/github/rscottlundgren/fidgot-personal`, or
   fast-forwards an existing clone (local changes are left alone).
2. Runs `go install ./...` there, which builds every Go tool into `~/go/bin`.
3. Runs the repo's own `check.sh`, which points out personal data a tool still
   needs on this machine. That data never lives in a repo, so it has to be
   filled in by hand, and keeping the list in fidgot-personal means this public
   repo doesn't name any personal tool.

Needs `git` and `go` (both in the common Brewfile) and, to clone the private
repo over HTTPS, a GitHub sign-in: `gh auth login`. The script stops with that
hint if you aren't signed in.
