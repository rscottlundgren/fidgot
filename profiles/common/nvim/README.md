# Neovim

- Started as a one-time copy of
  [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) (without its
  `.git` and `.github/`). Needs Neovim 0.12+; plugins install through `vim.pack`
  on first start. Kickstart's own README (install steps, FAQ) is
  [`KICKSTART.md`](KICKSTART.md).
- `nvim-pack-lock.json` is tracked so every machine gets the same plugin
  revisions. After `git pull` here, sync installed plugins to it with
  `:lua vim.pack.update(nil, { target = 'lockfile' })`. To update plugins, run
  `:lua vim.pack.update()` and commit the lockfile.
- Upstream keeps everything in one `init.lua`; here each of its sections is its
  own module under `lua/custom/` (the folder upstream promises never to touch),
  and `init.lua` requires them in a fixed order:

  | Upstream `init.lua` section                     | File here                                                         |
  | ----------------------------------------------- | ----------------------------------------------------------------- |
  | Header comment, 10: Optional examples           | `init.lua`                                                        |
  | 1: Options                                      | `lua/custom/config/options.lua`                                   |
  | 2: Keymaps & autocmds                           | `lua/custom/config/keymaps.lua`, `lua/custom/config/autocmds.lua` |
  | 3: Plugin manager intro (and the `gh()` helper) | `lua/custom/config/pack.lua`                                      |
  | 4: UI / core UX plugins                         | `lua/custom/plugins/ui.lua`                                       |
  | 5: Search & navigation                          | `lua/custom/plugins/telescope.lua`                                |
  | 6: LSP                                          | `lua/custom/plugins/lsp.lua`                                      |
  | 7: Formatting                                   | `lua/custom/plugins/formatting.lua`                               |
  | 8: Autocomplete & snippets                      | `lua/custom/plugins/completion.lua`                               |
  | 9: Treesitter                                   | `lua/custom/plugins/treesitter.lua`                               |

  `lua/kickstart/` (upstream's optional plugins) is kept identical to upstream.
  Upstream's `lua/custom/plugins/init.lua` auto-loader was removed: it loads
  files in no fixed order and would load these modules a second time.

- Plugins added here (not from upstream) get their own module, required after
  the section modules in `init.lua`, so the section files stay easy to compare
  with upstream:

  | Module                            | Plugin                                                                                                               |
  | --------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
  | `lua/custom/plugins/markdown.lua` | [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim): renders Markdown in the buffer |
  | `lua/custom/plugins/lint.lua`     | [nvim-lint](https://github.com/mfussenegger/nvim-lint): runs markdownlint-cli2 on Markdown buffers                   |

  Markdown is also formatted with Prettier on save and with `<leader>f`
  (`formatters_by_ft` and `format_on_save` in
  `lua/custom/plugins/formatting.lua`).

- `.luarc.json` points lua-language-server at the Neovim runtime and the
  installed plugins, so editors other than Neovim (e.g. Zed) know about the
  `vim` global and plugin types. lua-language-server reads it only from the
  workspace root, so there are copies in two places, kept identical:
  `profiles/common/nvim/.luarc.json` (Neovim's own `lua_ls`, or that folder
  opened alone) and the repo root (the whole repo opened, as in Zed). Zed also
  gets the same settings from the repo's `.zed/settings.json`. The runtime path,
  `/opt/homebrew/share/nvim/runtime`, assumes Homebrew on Apple Silicon; change
  it in all three on a machine where `:echo $VIMRUNTIME` is elsewhere.
- Kickstart's optional modules in `lua/kickstart/plugins/` are turned on by
  uncommenting their `require` in `init.lua` (section 10), and stay identical to
  upstream. Enabled: `autopairs` (closing brackets and quotes as you type).
  `lint` stays off: `lua/custom/plugins/lint.lua` replaces it.
- Languages each have a module in `lua/custom/languages/`, required from
  `init.lua` after the formatting and lint modules. A module enables the
  language server (nvim-lspconfig's default config) and adds the language's
  formatters to conform (`<leader>f`) and linters to nvim-lint. Their tools come
  from Homebrew (`profiles/common/Brewfile`), not Mason, so Neovim, Zed and the
  shell share them; Mason only installs what kickstart's `lsp.lua` lists
  (`lua_ls`, `stylua`).

  | Module                               | Language server                                                                                             | Formatters                                                      | Linters                                   |
  | ------------------------------------ | ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | ----------------------------------------- |
  | `go.lua`                             | gopls                                                                                                       | goimports, then gofumpt                                         | golangci-lint                             |
  | `typescript.lua`                     | vtsls; ESLint in projects with an ESLint config                                                             | Prettier (a project's own, if installed)                        | ESLint (through its language server)      |
  | `python.lua`                         | basedpyright (type checking `standard`); Ruff                                                               | Ruff: organize imports, then format                             | Ruff (through its language server)        |
  | `shell.lua` (sh, bash; not zsh)      | bash-language-server                                                                                        | shfmt, 2-space indent unless the project has an `.editorconfig` | shellcheck (through bash-language-server) |
  | `latex.lua`                          | texlab: build with latexmk (`:LspTexlabBuild`), forward search to Skim (`:LspTexlabForward`)                | tex-fmt                                                         | chktex on save (through texlab)           |
  | `java.lua`                           | jdtls (type checking needs a project root: `.git`, `pom.xml`, `build.gradle`, …)                            | google-java-format                                              | jdtls                                     |
  | `web.lua` (HTML, CSS, SCSS, Less)    | html, cssls (vscode-langservers-extracted)                                                                  | Prettier                                                        | cssls (CSS validation)                    |
  | `data.lua` (JSON, JSONC, YAML, TOML) | jsonls, yamlls (schemas from SchemaStore.nvim), taplo                                                       | Prettier (JSON, YAML); taplo (TOML)                             | the language servers (schema validation)  |
  | `rust.lua`                           | rust-analyzer (from the rustup toolchain)                                                                   | rustfmt                                                         | clippy (through rust-analyzer, on save)   |
  | `zig.lua`                            | zls (syntax errors as you type; compile errors on save when `build.zig` has a `check` step, see the module) | `zig fmt`                                                       | zls                                       |

- Nerd Font icons are on (`vim.g.have_nerd_font = true` in
  `lua/custom/config/options.lua`): kickstart then loads mini.icons (also
  standing in for nvim-web-devicons, which Telescope uses) and shows icons in
  which-key and the statusline, and render-markdown uses mini.icons for code
  block icons. The terminal must use a Nerd Font; Ghostty's is CommitMono Nerd
  Font Mono (see [Ghostty](../ghostty/README.md)).
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
  file for that section (table above). Changes under `lua/kickstart/` copy over
  as-is. Upstream's `README.md` is `KICKSTART.md` here; it and `LICENSE.md` are
  formatted with Prettier, so port their changes by hand and run
  `prettier --write` on them. Then write the clone's `git rev-parse HEAD` into
  `.kickstart-synced`.
