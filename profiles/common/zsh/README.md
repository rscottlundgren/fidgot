# zsh

`zprofile` (login shells) and `zshrc` (interactive shells), linked to
`~/.zprofile` and `~/.zshrc`. macOS terminals, Ghostty included, start login
shells, so both run in a new window or tab.

- `zprofile`: Homebrew's environment (`brew shellenv`, for either Homebrew
  prefix) and OrbStack's shell integration (its command-line tools on `PATH`).
- `zshrc`:
  - Starship prompt (config in [`../starship/`](../starship/README.md)).
  - nvm, for Node.
  - `brew-in` / `brew-un` / `brew-up`: install, uninstall or upgrade with
    `brew doctor`, `update`, `upgrade` and `cleanup` around it.
  - 1Password CLI shell plugins, from `~/.config/op/plugins.sh` if it exists.
    `op plugin init` generates that file, so it isn't tracked.
  - `PATH` additions: `~/go/bin` (Go tools, e.g. the handoff helper), rustup's
    `bin` folder (Homebrew's rustup doesn't add it) and `~/.cargo/bin`
    (`cargo install` tools) if they exist, Homebrew's `openjdk` (keg-only, so
    not linked by Homebrew) with `JAVA_HOME`, and `~/.local/bin` (Postman CLI).
  - `els`, if eza is installed: `eza` with folders first, icons, and git status
    and relative times in long views. Flags pass through: `els -l`, `els -la`,
    `els -T -L2` (tree). Plain `ls` is unchanged.
  - `~/.zshrc.local` last, if it exists: machine-specific settings (work hosts,
    tokens, local paths). Not tracked; this repo is public.

Every piece that depends on something being installed is guarded, so the files
load without errors on a machine that doesn't have it.

Installers that append to `~/.zshrc` or `~/.zprofile` (as OrbStack and Postman
did) write through the links into this folder; review and commit those changes,
or move them to `~/.zshrc.local` if they're machine-specific.
