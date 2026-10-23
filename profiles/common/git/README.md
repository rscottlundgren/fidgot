# git

`gitconfig` and `ignore`, linked to `~/.gitconfig` and `~/.config/git/ignore`
(file links: `~/.config/git/` also holds files that aren't tracked).

- Commits are signed with an SSH key in 1Password (`op-ssh-sign`), and
  `allowed_signers` lets `git log --show-signature` verify them.
- There's no global name or email. An identity file is included by folder:
  `~/git/github/rscottlundgren/` → `~/.config/git/rscottlundgren.gitconfig`,
  `~/git/github/studio-elif/` → `~/.config/git/studioelif.gitconfig`. Outside
  those folders a commit fails for lack of an identity, on purpose.
- GitHub over HTTPS authenticates through `gh auth git-credential`.
- Git LFS filters.
- `~/.config/git/local.gitconfig` is included last if it exists:
  machine-specific settings, e.g. a work identity for a work folder with its own
  `includeIf`.

`ignore` is the global ignore list (currently Claude Code's per-project
`settings.local.json`).

## Not in this repo

These hold email addresses or keys (this repo is public), so create them on each
machine that needs them:

- `~/.config/git/<identity>.gitconfig`, one per identity:

  ```ini
  [user]
    name = Your Name
    email = you@example.com
    signingkey = ssh-ed25519 AAAA… (public key from 1Password)
  ```

- `~/.config/git/allowed_signers`, one line per signing identity:
  `you@example.com namespaces="git" ssh-ed25519 AAAA…`
