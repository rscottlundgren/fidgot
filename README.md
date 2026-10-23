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
   upgrade).
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

## Install

Homebrew installs are listed in Brewfiles, one per profile (see Config below):

- `profiles/common/Brewfile`: every machine (tools, editors, fonts, apps)
- `profiles/personal/Brewfile`: the personal machine only

```sh
brew bundle install --file profiles/common/Brewfile
brew bundle install --file profiles/personal/Brewfile   # personal machine
brew bundle check --file profiles/common/Brewfile       # what's missing
```

`brew bundle cleanup` compares against one Brewfile, so combine them to see
what's installed but listed in neither:

```sh
cat profiles/*/Brewfile | brew bundle cleanup --file=-
```

On this machine that lists only `task`, `timewarrior` and `zk`, which are
deliberately left out for now.

Notes:

- Docker comes from OrbStack, which includes the Docker CLI, `docker compose`
  and `docker buildx`. Homebrew's `docker` formula is left out on purpose:
  OrbStack would defer to it, and it needs separate Compose and buildx formulas.
- Kubernetes is OrbStack's local single-node cluster: turn it on with
  `orb start k8s` (context `orbstack`). OrbStack's bundled `kubectl` is too far
  behind the cluster's version, so `kubectl` comes from Homebrew's
  `kubernetes-cli`, which is earlier on `PATH`.
- Terraform isn't in Homebrew's core repository any more; it comes from
  HashiCorp's tap (`hashicorp/tap`).
- Rust comes from Homebrew's `rustup`, which manages the toolchains. On a new
  machine, after `brew bundle install`: `rustup default stable` and
  `rustup component add rust-analyzer`. Update with `rustup update`. Don't also
  install Homebrew's `rust` formula; it's a separate toolchain that conflicts.
- Zig and its language server, ZLS, both come from Homebrew. ZLS has to be the
  same release as Zig, so upgrade them together: `brew upgrade zig zls`.

Installed outside Homebrew:

- Node, through [nvm](https://github.com/nvm-sh/nvm) (its maintainers ask not to
  install it with Homebrew):

  ```sh
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
  nvm install --lts
  ```

- pnpm and yarn, through Node's corepack: `corepack enable pnpm`. Each project
  pins its version with `packageManager` in `package.json`.

Coding-agent setup (Claude Code config from the private agent-config repo):
[`profiles/common/agents/`](profiles/common/agents/README.md).

## Config

App configuration that lives in this repo and is linked into place. It's grouped
into profiles by which machines use it:

| Profile              | For                               | Contains                                               |
| -------------------- | --------------------------------- | ------------------------------------------------------ |
| `profiles/common/`   | Every machine (personal and work) | Brewfile, zsh, git, gh, Neovim, Ghostty, Starship, Zed |
| `profiles/personal/` | The personal machine only         | Brewfile, `life-ops` scripts                           |

Config starts in `common/`. Something moves to a machine-specific profile only
when it has to differ between machines; a work profile would sit next to
`personal/` the same way. Small per-machine tweaks that don't justify a profile
stay out of the repo (e.g. Neovim's `lua/custom/local.lua`).

Each tool's folder has a README with the notes for that tool.

| Tool                                           | In repo                                                  | Linked to                              | Restore on a new machine                                                                                                                                                          |
| ---------------------------------------------- | -------------------------------------------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Zed](profiles/common/zed/README.md)           | `profiles/common/zed/` (`settings.json`, `themes/`)      | `~/.config/zed` (whole directory)      | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/zed ~/.config/zed`                                                                                                      |
| [Ghostty](profiles/common/ghostty/README.md)   | `profiles/common/ghostty/` (`config.ghostty`, `themes/`) | `~/.config/ghostty` (whole directory)  | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/ghostty ~/.config/ghostty`                                                                                              |
| [Starship](profiles/common/starship/README.md) | `profiles/common/starship/starship.toml`                 | `~/.config/starship.toml`              | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/starship/starship.toml ~/.config/starship.toml`                                                                         |
| [Neovim](profiles/common/nvim/README.md)       | `profiles/common/nvim/` (kickstart.nvim copy)            | `~/.config/nvim` (whole directory)     | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/nvim ~/.config/nvim`                                                                                                    |
| [zsh](profiles/common/zsh/README.md)           | `profiles/common/zsh/` (`zshrc`, `zprofile`)             | `~/.zshrc`, `~/.zprofile`              | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/zsh/zshrc ~/.zshrc && ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/zsh/zprofile ~/.zprofile`                |
| [git](profiles/common/git/README.md)           | `profiles/common/git/` (`gitconfig`, `ignore`)           | `~/.gitconfig`, `~/.config/git/ignore` | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/git/gitconfig ~/.gitconfig && ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/git/ignore ~/.config/git/ignore` |
| [gh](profiles/common/gh/README.md)             | `profiles/common/gh/config.yml`                          | `~/.config/gh/config.yml`              | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/gh/config.yml ~/.config/gh/config.yml`                                                                                  |

## Third-party clones

Clones of other people's repos live at
`~/git/github/<account>/_third-party/<owner>/<repo>` (for example
`rscottlundgren/_third-party/nvim-lua/kickstart.nvim`), apart from my own
projects. Keeping them under the account folder means that account's git
identity still applies. The leading `_` sorts the folder first.

## Markdown

Markdown is formatted with Prettier and linted with markdownlint-cli2, using
config at the repo root, so Neovim, Zed and the command line agree:

- `.prettierrc`: wrap prose at 80 columns (`proseWrap: "always"`). Zed's
  built-in Prettier reads it. It also formats JSONC (`*.jsonc` and Zed's
  `settings.json` files) with trailing commas, as Zed writes them.
- `.markdownlint-cli2.jsonc`: markdownlint's Prettier style (turns off rules
  that conflict with Prettier) plus line length 80, not applied to code blocks
  or tables.
- `.prettierignore`: skips Neovim's help files and the local `.context/` notes.

From the repo root:

```sh
prettier --check '**/*.md'      # or --write to format
markdownlint-cli2 '**/*.md'     # or --fix for what it can fix itself
```
