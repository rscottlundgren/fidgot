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

| Tool | In repo | Linked to | Restore on a new machine |
| --- | --- | --- | --- |
| Zed | `profiles/personal/zed/` (`settings.json`, `themes/`) | `~/.config/zed` (whole directory) | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/personal/zed ~/.config/zed` |
| Ghostty | `profiles/personal/ghostty/` (`config.ghostty`, `themes/`) | `~/.config/ghostty` (whole directory) | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/personal/ghostty ~/.config/ghostty` |
| Starship | `profiles/personal/starship/starship.toml` | `~/.config/starship.toml` | `ln -s ~/git/github/rscottlundgren/fidgot/profiles/personal/starship/starship.toml ~/.config/starship.toml` |

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
