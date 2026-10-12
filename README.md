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

The whole Zed folder is linked (not just `settings.json`) so Zed's own saves,
which write a temp file and rename it, stay inside the repo instead of
replacing a file-level link. Zed's prompt-library database and `*.bak-*`
backups live there too but are git-ignored.

Zed settings include per-language column rulers (`wrap_guides`) set to each
language's community line length (PEP 8, Prettier, RuboCop, swift-format,
clang-format, …); see the comments in `settings.json`.
