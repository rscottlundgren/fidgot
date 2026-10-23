# fidgot

My dotfiles and app config, shared across machines.

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

Installed outside Homebrew:

- Node, through [nvm](https://github.com/nvm-sh/nvm) (its maintainers ask not to
  install it with Homebrew):

  ```sh
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash
  nvm install --lts
  ```

- pnpm and yarn, through Node's corepack: `corepack enable pnpm`. Each project
  pins its version with `packageManager` in `package.json`.

## Config

App configuration that lives in this repo and is linked into place. It's grouped
into profiles by which machines use it:

| Profile              | For                               | Contains                                 |
| -------------------- | --------------------------------- | ---------------------------------------- |
| `profiles/common/`   | Every machine (personal and work) | Brewfile, Neovim, Ghostty, Starship, Zed |
| `profiles/personal/` | The personal machine only         | Brewfile, `life-ops` scripts             |

Config starts in `common/`. Something moves to a machine-specific profile only
when it has to differ between machines; a work profile would sit next to
`personal/` the same way. Small per-machine tweaks that don't justify a profile
stay out of the repo (e.g. Neovim's `lua/custom/local.lua`).

Each tool's folder has a README with the notes for that tool.

| Tool                                           | In repo                                                  | Linked to                             | Restore on a new machine                                                                                  |
| ---------------------------------------------- | -------------------------------------------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| [Zed](profiles/common/zed/README.md)           | `profiles/common/zed/` (`settings.json`, `themes/`)      | `~/.config/zed` (whole directory)     | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/zed ~/.config/zed`                              |
| [Ghostty](profiles/common/ghostty/README.md)   | `profiles/common/ghostty/` (`config.ghostty`, `themes/`) | `~/.config/ghostty` (whole directory) | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/ghostty ~/.config/ghostty`                      |
| [Starship](profiles/common/starship/README.md) | `profiles/common/starship/starship.toml`                 | `~/.config/starship.toml`             | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/starship/starship.toml ~/.config/starship.toml` |
| [Neovim](profiles/common/nvim/README.md)       | `profiles/common/nvim/` (kickstart.nvim copy)            | `~/.config/nvim` (whole directory)    | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/nvim ~/.config/nvim`                            |

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
  built-in Prettier reads it.
- `.markdownlint-cli2.jsonc`: markdownlint's Prettier style (turns off rules
  that conflict with Prettier) plus line length 80, not applied to code blocks
  or tables.
- `.prettierignore`: skips Neovim's help files and the local `.context/` notes.

From the repo root:

```sh
prettier --check '**/*.md'      # or --write to format
markdownlint-cli2 '**/*.md'     # or --fix for what it can fix itself
```
