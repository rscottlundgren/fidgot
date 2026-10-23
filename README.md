## Git

# Casks

| Seq | Tool | Installed By | Managed By | Install Command | Notes |
| --- | --- | --- | --- | --- | --- |
| ?? | [WhatsApp]() | Homebrew | Homebrew + Self | `brew install --cask whatsapp` | N / A |
| ?? | [Ghostty]() | Homebrew | Homebrew + Self | `brew install --cask ghostty` | N / A |
| ?? | [Zoom]() | Homebrew | Homebrew + Self | `brew install --cask zoom` | N / A |
| ?? | [VS Code]() | Homebrew | Homebrew + Self | `brew install --cask visual-studio-code` | N / A |
| ?? | [Zed]() | Homebrew | Homebrew + Self | `brew install --cask zed` | N / A |
| ?? | [Nerd Font: CommitMono]() | Homebrew | Homebrew | `brew install --cask font-commit-mono-nerd-font` | N / A |
| ?? | [Nerd Font: GeistMono]() | Homebrew | Homebrew | `brew install --cask font-geist-mono-nerd-font` | N / A |
| ?? | [Nerd Font: ZedMono]() | Homebrew | Homebrew | `brew install --cask font-zed-mono-nerd-font` | N / A |

# Formulae

| Seq | Tool | Installed By | Managed By | Install Command | Notes |
| --- | --- | --- | --- | --- | --- |
| ?? | [Starship](https://starship.rs/) | Homebrew | Homebrew | `brew install starship` | N / A |
| ?? | [gh]() | Homebrew | Homebrew | `brew install gh` | N / A |

# Config

App configuration that lives in this repo and is linked into place.
`profiles/common/` holds config shared by every machine; `profiles/personal/`
holds config for the personal machine only.

| Tool | In repo | Linked to | Restore on a new machine |
| --- | --- | --- | --- |
| Zed | `profiles/personal/zed/` (`settings.json`, `themes/`) | `~/.config/zed` (whole directory) | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/personal/zed ~/.config/zed` |
| Ghostty | `profiles/personal/ghostty/` (`config.ghostty`, `themes/`) | `~/.config/ghostty` (whole directory) | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/personal/ghostty ~/.config/ghostty` |
| Starship | `profiles/personal/starship/starship.toml` | `~/.config/starship.toml` | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/personal/starship/starship.toml ~/.config/starship.toml` |
| Neovim | `profiles/common/nvim/` (kickstart.nvim copy) | `~/.config/nvim` (whole directory) | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/common/nvim ~/.config/nvim` |

The whole Zed folder is linked (not just `settings.json`) so Zed's own saves,
which write a temp file and rename it, stay inside the repo instead of
replacing a file-level link. Zed's prompt-library database and `*.bak-*`
backups live there too but are git-ignored.

Zed settings include per-language column rulers (`wrap_guides`) set to each
language's community line length (PEP 8, Prettier, RuboCop, swift-format,
clang-format, …); see the comments in `settings.json`.

Ghostty:

- It also reads `~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`
  after the linked file, so keep that one absent or it overrides the repo.
- The window is translucent (`background-opacity`, the one value to change).
  `background-opacity-cells` applies the same opacity to highlighted lines,
  diff colors and the Starship prompt segments. Text selection is the
  exception: Ghostty always draws it solid, so it uses a muted mustard.
- It stays transparent in fullscreen only in its own (non-native) mode: enter
  fullscreen with `cmd-enter`. The green button and `cmd-ctrl-F` use macOS
  native fullscreen, where Ghostty turns transparency off.
- The themes are tuned copies of Ghostty's Atom One in `themes/`, for
  readability over the translucent background: `Atom One Dark Bright`
  (brighter text) and `Atom One Light Deep` (darker green/red/yellow), both
  with the mustard selection. Ghostty finds them through the linked folder.
- The font is CommitMono Nerd Font **Mono**, which fits every icon into one
  cell so icons stay centered (the non-Mono variant draws some, like the
  Apple logo, wider and off-center).

Starship:

- Needs `eval "$(starship init zsh)"` in `~/.zshrc`. Segment colors are listed
  at the top of `starship.toml`.
- Segments are flat blocks rather than powerline arrows: terminal glyphs are
  always opaque, so arrow shapes can't match translucent segment bodies.
- Git status uses Nerd Font icons; the comments above `[git_status]` say which
  icon replaced which symbol.
- Paths show up to 5 folders, counted from the repo root inside a repo, with
  the repo name in bold.

Neovim:

- Started as a one-time copy of
  [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (without its
  `.git` and `.github/`). Needs Neovim 0.12+; plugins install through
  `vim.pack` on first start.
- `nvim-pack-lock.json` is tracked so every machine gets the same plugin
  revisions. After `git pull` here, sync installed plugins to it with
  `:lua vim.pack.update(nil, { target = 'lockfile' })`. To update plugins, run
  `:lua vim.pack.update()` and commit the lockfile.
- Upstream keeps everything in one `init.lua`; here each of its sections is
  its own module under `lua/custom/` (the folder upstream promises never to
  touch), and `init.lua` requires them in a fixed order:

  | Upstream `init.lua` section | File here |
  | --- | --- |
  | Header comment, 10: Optional examples | `init.lua` |
  | 1: Options | `lua/custom/config/options.lua` |
  | 2: Keymaps & autocmds | `lua/custom/config/keymaps.lua`, `lua/custom/config/autocmds.lua` |
  | 3: Plugin manager intro (and the `gh()` helper) | `lua/custom/config/pack.lua` |
  | 4: UI / core UX plugins | `lua/custom/plugins/ui.lua` |
  | 5: Search & navigation | `lua/custom/plugins/telescope.lua` |
  | 6: LSP | `lua/custom/plugins/lsp.lua` |
  | 7: Formatting | `lua/custom/plugins/formatting.lua` |
  | 8: Autocomplete & snippets | `lua/custom/plugins/completion.lua` |
  | 9: Treesitter | `lua/custom/plugins/treesitter.lua` |

  `lua/kickstart/` (upstream's optional plugins) is kept identical to upstream.
  Upstream's `lua/custom/plugins/init.lua` auto-loader was removed: it loads
  files in no fixed order and would load these modules a second time.
- Machine-specific settings (work hostnames, paths, anything not for a public
  repo) go in `lua/custom/local.lua`. It's git-ignored, and `init.lua` loads it
  only if it exists.
- Upstream changes are reviewed in a read-only clone and ported by hand.
  `.kickstart-synced` holds the last upstream commit ported. In the clone:

  ```sh
  cd ~/git/github/rscottlundgren/_third-party/nvim-lua/kickstart.nvim
  git pull --ff-only
  git log  $(cat ~/git/github/rscottlundgren/fidgot/profiles/common/nvim/.kickstart-synced)..HEAD
  git diff $(cat ~/git/github/rscottlundgren/fidgot/profiles/common/nvim/.kickstart-synced)..HEAD
  ```

  Each hunk in `init.lua` falls under a `SECTION N` banner; port it into the
  file for that section (table above). Changes under `lua/kickstart/` copy
  over as-is. Then write the clone's `git rev-parse HEAD` into
  `.kickstart-synced`.

# Third-party clones

Clones of other people's repos live at
`~/git/github/<account>/_third-party/<owner>/<repo>` (for example
`rscottlundgren/_third-party/nvim-lua/kickstart.nvim`), apart from my own
projects. Keeping them under the account folder means that account's git
identity still applies. The leading `_` sorts the folder first.
