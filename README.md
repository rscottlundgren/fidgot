# fidgot

My dotfiles and app config, shared across machines.

## Set up a machine

On a new Mac, install Apple's Command Line Tools (for `git`), clone this repo
(it's public, so HTTPS needs no sign-in) and run `install.sh`:

```sh
xcode-select --install
git clone https://github.com/rscottlundgren/fidgot.git ~/git/github/rscottlundgren/fidgot
cd ~/git/github/rscottlundgren/fidgot
./install.sh --profile personal --dry-run   # preview
./install.sh --profile personal
```

On a work machine, use that machine's profile name instead of `personal` (e.g.
`./install.sh --profile <work-profile>`): it installs only the common Brewfile,
and passes the name to the coding-agent setup.

`install.sh` runs these steps, each skipping what's already in place, so it's
safe to rerun (`--skip <steps>` leaves some out):

1. `xcode`: Command Line Tools.
2. `brew`: Homebrew, then the Brewfiles (installs what's missing; doesn't
   upgrade). What's in them: [`profiles/common/`](profiles/common/README.md).
3. `links`: links every tracked config into place (the Config table below);
   anything in the way is renamed `*.bak-<timestamp>`.
4. `toolchains`: Rust's stable toolchain and rust-analyzer (rustup), nvm with
   Node LTS, and pnpm through corepack.
5. `nvim`: Neovim plugins at the lockfile's revisions.
6. `agents`: the coding-agent config
   ([`profiles/common/agents/`](profiles/common/agents/README.md)), which needs
   `gh auth login` first.

It ends with what's left to do by hand: OrbStack's first launch, 1Password's SSH
agent, `gh auth login`, git identities, and machine-specific settings.

### Folder layout

Repos live in `~/git/github/<account>/<repo>`; git picks the identity for a
commit by that folder (see [git](profiles/common/git/README.md)), so this repo
and the coding-agent repos are cloned under `rscottlundgren/`. Clones of other
people's repos go in `~/git/github/<account>/_third-party/<owner>/<repo>` (e.g.
`rscottlundgren/_third-party/nvim-lua/kickstart.nvim`), apart from my own
projects but still under the account's identity; the leading `_` sorts the
folder first.

## Profiles

Config is grouped into profiles by which machines use it:

| Profile              | For                               | Contains                                               |
| -------------------- | --------------------------------- | ------------------------------------------------------ |
| `profiles/common/`   | Every machine (personal and work) | Brewfile, zsh, git, gh, Neovim, Ghostty, Starship, Zed |
| `profiles/personal/` | The personal machine only         | Brewfile, `life-ops` scripts                           |

Config starts in `common/`. Something moves to a machine-specific profile only
when it has to differ between machines; a work profile would sit next to
`personal/` the same way. Small per-machine tweaks that don't justify a profile
stay out of the repo (e.g. `~/.zshrc.local`, Neovim's `lua/custom/local.lua`).

## Config

App configuration that lives in this repo and is linked into place by
`install.sh` (its `links` list). Each folder's README has the notes for that
tool.

| Tool                                           | In repo                                                  | Linked to                              |
| ---------------------------------------------- | -------------------------------------------------------- | -------------------------------------- |
| [zsh](profiles/common/zsh/README.md)           | `profiles/common/zsh/` (`zshrc`, `zprofile`)             | `~/.zshrc`, `~/.zprofile`              |
| [git](profiles/common/git/README.md)           | `profiles/common/git/` (`gitconfig`, `ignore`)           | `~/.gitconfig`, `~/.config/git/ignore` |
| [gh](profiles/common/gh/README.md)             | `profiles/common/gh/config.yml`                          | `~/.config/gh/config.yml`              |
| [Neovim](profiles/common/nvim/README.md)       | `profiles/common/nvim/` (kickstart.nvim, modularized)    | `~/.config/nvim` (whole directory)     |
| [Ghostty](profiles/common/ghostty/README.md)   | `profiles/common/ghostty/` (`config.ghostty`, `themes/`) | `~/.config/ghostty` (whole directory)  |
| [Starship](profiles/common/starship/README.md) | `profiles/common/starship/starship.toml`                 | `~/.config/starship.toml`              |
| [Zed](profiles/common/zed/README.md)           | `profiles/common/zed/` (`settings.json`, `themes/`)      | `~/.config/zed` (whole directory)      |

## Repo tooling

Settings that apply to working on this repo itself, at the repo root:

- `.editorconfig`: UTF-8, LF line endings, a final newline, no trailing
  whitespace and 2-space indents everywhere (tabs in git config files). Zed,
  Neovim and VS Code read it, as do shfmt (so shell scripts get 2 spaces) and
  Prettier; it mostly matters for files no formatter covers, like the Brewfiles,
  zsh and Ghostty config.
- `.prettierrc`: Prettier formats Markdown with prose wrapped at 80 columns
  (`proseWrap: "always"`), and JSONC (`*.jsonc` and Zed's `settings.json` files)
  with trailing commas, as Zed writes them. Zed's built-in Prettier reads it
  too.
- `.markdownlint-cli2.jsonc`: markdownlint's Prettier style (turns off rules
  that conflict with Prettier) plus line length 80, not applied to code blocks
  or tables.
- `.prettierignore`: skips Neovim's help files and the local `.context/` notes.
- `.luarc.json` and `.zed/settings.json`: tell lua-language-server about the
  Neovim runtime when the whole repo is open in an editor such as Zed (see
  [Neovim](profiles/common/nvim/README.md)).

Tests for the scripts, shell and Neovim config are in
[`tests/`](tests/README.md): run `tests/run.sh` before committing (it includes
the Markdown checks below), or `tests/run.sh --slow` after changing a language
module.

Check Markdown before committing:

```sh
prettier --check '**/*.md'      # or --write to format
markdownlint-cli2 '**/*.md'     # or --fix for what it can fix itself
```

## License

Not licensed for reuse yet: the repo is public for reference, and everything in
it is copyright R. Scott Lundgren with all rights reserved (see
[`LICENSE`](LICENSE)). An open-source license is planned once the repo is ready
for others to use. The Neovim config in `profiles/common/nvim/` is derived from
kickstart.nvim and keeps its MIT license
([`LICENSE.md`](profiles/common/nvim/LICENSE.md)).
