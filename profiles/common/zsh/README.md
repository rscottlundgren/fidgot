# zsh

`zprofile` (login shells) and `zshrc` (interactive shells), linked to
`~/.zprofile` and `~/.zshrc`. macOS terminals, Ghostty included, start login
shells, so both run in a new window or tab.

- `zprofile`: Homebrew's environment (`brew shellenv`, for either Homebrew
  prefix) and OrbStack's shell integration (its command-line tools on `PATH`).
- `zshrc`, in sections in this order (each section depends only on the ones
  above it):
  - **Prompt**: Starship (config in [`../starship/`](../starship/README.md)).
  - **Toolchains & PATH**: nvm, for Node; then `~/go/bin` (Go tools, e.g. the
    handoff helper), rustup's `bin` folder (Homebrew's rustup doesn't add it)
    and `~/.cargo/bin` (`cargo install` tools) if they exist, Homebrew's
    `openjdk` (keg-only, so not linked by Homebrew) with `JAVA_HOME`, and
    `~/.local/bin` (Postman CLI). Each addition goes in front of the ones before
    it.
  - **Tools**, after PATH so their checks find the commands: 1Password CLI shell
    plugins, from `~/.config/op/plugins.sh` if it exists (`op plugin init`
    generates that file, so it isn't tracked); and `els`, if eza is installed:
    `eza` with folders first, icons, and git status and relative times in long
    views. Flags pass through: `els -l`, `els -la`, `els -T -L2` (tree). Plain
    `ls` is unchanged.
  - **Shell functions**: every `functions/*.zsh` file, in name order (see
    below).
  - **Machine-specific**, last: `~/.zshrc.local`, if it exists, for work hosts,
    tokens and local paths. Not tracked; this repo is public.

New settings go in the section they belong to, not at the end of the file.

Every piece that depends on something being installed is guarded, so the files
load without errors on a machine that doesn't have it.

Installers that append to `~/.zshrc` or `~/.zprofile` (as OrbStack and Postman
did) write through the links into this folder, at the end of the file, after
`~/.zshrc.local`. Move what they add into its section and commit it, or into
`~/.zshrc.local` if it's machine-specific.

## Conventions

These files follow the repo-wide [CONVENTIONS.md](../../../CONVENTIONS.md):
section rules, 80 columns, comments above code, full-word names. On top of
those:

- shellcheck reads these files as bash, and each one says so on its first line.
  `zshrc` and `zprofile` also turn off SC1090 and SC1091 there, for the whole
  file, since every file they source (nvm, 1Password's plugins, OrbStack,
  `~/.zshrc.local`, `functions/*.zsh`) only exists at runtime:

  ```zsh
  # shellcheck shell=bash disable=SC1090,SC1091
  ```

- zsh has special lowercase parameters that a full word can collide with: `path`
  is tied to `PATH` (so `local path` empties `PATH` inside that function), and
  `status`, `options`, `functions`, `commands` and `aliases` are taken too.
  `time` is a zsh keyword. Pick another word, e.g. `target` for a path, `clock`
  for a time.

## Shell functions

`zshrc` sources every `functions/*.zsh` file without naming them, so adding a
file is enough. They're sourced from inside a function, so a file should only
define functions: a `setopt` or `local` at its top level wouldn't outlast the
loading. One file per subject:

- `brew.zsh`: `brew-in` / `brew-un` / `brew-up` install, uninstall or upgrade
  with `brew doctor`, `update`, `upgrade --greedy` and `cleanup` around it.
  `brew-in` and `brew-un` need at least one formula or cask. A failed `update`,
  install or uninstall stops before `cleanup`; a failed `upgrade` doesn't block
  the install, and `doctor`'s warnings don't count as a failure. `--greedy` also
  upgrades casks that update themselves (browsers, editors, 1Password) or are
  versioned `latest`, which `brew upgrade` skips on its own.

Keep functions for things that are only typed at a prompt or have to change the
current shell. A command that other scripts should be able to run belongs on
`PATH` instead.
