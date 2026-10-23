# tests

Tests for fidgot, written in Go with the standard `testing` package. They check
the repo from the outside, running the scripts, shells and editors the way a
person would and then looking at what happened, so the scripts themselves stay
in shell.

## Run

```sh
tests/run.sh                 # fast tests, a few seconds
tests/run.sh --slow          # also the language servers, about 15 seconds
tests/run.sh -run Install    # only tests whose names match; -v lists each one
```

`run.sh` runs `go test` (never with cached results, since they depend on the
machine). It then warns, without failing, if the common Brewfile isn't fully
installed: that's the machine's state, not the repo's.

They need a set-up machine: the Brewfiles installed and Neovim's plugins in
place (`install.sh` does both). `--slow` also needs every language server,
including rust-analyzer from rustup and lua-language-server from Mason.

## What they check

| File                     | Checks                                                                                                                                                                                         |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `hygiene_test.go`        | shellcheck and shfmt on the scripts, `zsh -n` on the zsh config, stylua, gofmt, Prettier and markdownlint                                                                                      |
| `install_test.go`        | `install.sh` in an empty temporary `HOME` (links step only): every link made, a second run changes nothing, a file in the way is backed up, `--dry-run` changes nothing, bad arguments exit 2  |
| `agents_test.go`         | `agents/setup.sh`: arguments, and a dry run doesn't clone                                                                                                                                      |
| `zsh_test.go`            | A login shell with the tracked config: nothing on stderr, the expected `PATH` entries, `~/.zshrc.local` loaded only when present                                                               |
| `nvim_test.go`           | Headless Neovim with the repo's config: clean start with every plugin loaded, `:checkhealth kickstart`, spell checking on for prose and off for code, Lua and Markdown format on save          |
| `languages_slow_test.go` | `--slow` only: for each language module, its fixture gets the language server, the expected diagnostic and the expected formatting; lua-language-server finds no warnings in the Neovim config |

life-ops isn't tested yet.

## How they're built

- Each Neovim check is a Lua script in `nvim/`, run by `nvim_test.go` in
  headless Neovim with the repo's config (through `XDG_CONFIG_HOME`), a login
  shell's `PATH`, and temporary state and cache folders. Scripts report with
  `check()` from `nvim/lib.lua`; a failure exits non-zero and prints `FAIL:`
  lines.
- Language fixtures live in `testdata/<language>/`. Each has a file with a
  deliberate error and messy formatting, and next to it the expected formatter
  output (`<file>.formatted`). The test copies the folder to a temporary one
  first, so build output (Cargo, jdtls) never lands in the repo. Go ignores
  `testdata/`, and the hygiene checks and Prettier skip it.
- To cover a new language: add its fixture and a row in the `languages` table in
  `languages_slow_test.go`.

## CI

The `devops` repo is meant to run the fast tests (`tests/run.sh`) on a macOS
runner after installing the Brewfiles and Neovim's plugins.
