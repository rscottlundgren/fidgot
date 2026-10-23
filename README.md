# fidgot

My dotfiles and app config, shared across machines.

## Casks

| Seq | Tool                                                | Installed By | Managed By      | Install Command                                  | Notes |
| --- | --------------------------------------------------- | ------------ | --------------- | ------------------------------------------------ | ----- |
| ??  | [WhatsApp](https://www.whatsapp.com/)               | Homebrew     | Homebrew + Self | `brew install --cask whatsapp`                   | N / A |
| ??  | [Ghostty](https://ghostty.org/)                     | Homebrew     | Homebrew + Self | `brew install --cask ghostty`                    | N / A |
| ??  | [Zoom](https://zoom.us/)                            | Homebrew     | Homebrew + Self | `brew install --cask zoom`                       | N / A |
| ??  | [VS Code](https://code.visualstudio.com/)           | Homebrew     | Homebrew + Self | `brew install --cask visual-studio-code`         | N / A |
| ??  | [Zed](https://zed.dev/)                             | Homebrew     | Homebrew + Self | `brew install --cask zed`                        | N / A |
| ??  | [Nerd Font: CommitMono](https://www.nerdfonts.com/) | Homebrew     | Homebrew        | `brew install --cask font-commit-mono-nerd-font` | N / A |
| ??  | [Nerd Font: GeistMono](https://www.nerdfonts.com/)  | Homebrew     | Homebrew        | `brew install --cask font-geist-mono-nerd-font`  | N / A |
| ??  | [Nerd Font: ZedMono](https://www.nerdfonts.com/)    | Homebrew     | Homebrew        | `brew install --cask font-zed-mono-nerd-font`    | N / A |

## Formulae

| Seq | Tool                                                                 | Installed By | Managed By | Install Command                  | Notes                                |
| --- | -------------------------------------------------------------------- | ------------ | ---------- | -------------------------------- | ------------------------------------ |
| ??  | [Starship](https://starship.rs/)                                     | Homebrew     | Homebrew   | `brew install starship`          | N / A                                |
| ??  | [gh](https://cli.github.com/)                                        | Homebrew     | Homebrew   | `brew install gh`                | N / A                                |
| ??  | [Prettier](https://prettier.io/)                                     | Homebrew     | Homebrew   | `brew install prettier`          | Formats Markdown; see Markdown below |
| ??  | [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) | Homebrew     | Homebrew   | `brew install markdownlint-cli2` | Lints Markdown; see Markdown below   |

## Config

App configuration that lives in this repo and is linked into place. It's grouped
into profiles by which machines use it:

| Profile              | For                               | Contains                       |
| -------------------- | --------------------------------- | ------------------------------ |
| `profiles/common/`   | Every machine (personal and work) | Neovim, Ghostty, Starship, Zed |
| `profiles/personal/` | The personal machine only         | `life-ops` scripts             |

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
