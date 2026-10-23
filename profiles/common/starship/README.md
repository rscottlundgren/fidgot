# Starship

- Needs `eval "$(starship init zsh)"` in `~/.zshrc`. Segment colors are listed
  at the top of `starship.toml`.
- Segments are flat blocks rather than powerline arrows: terminal glyphs are
  always opaque, so arrow shapes can't match translucent segment bodies.
- Git status uses Nerd Font icons; the comments above `[git_status]` say which
  icon replaced which symbol.
- Paths show up to 5 folders, counted from the repo root inside a repo, with the
  repo name in bold.
