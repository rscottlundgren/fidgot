-- [[ Go ]]
-- Not part of upstream kickstart.
--
-- Tools come from Homebrew (profiles/common/Brewfile), not Mason, so Neovim,
-- Zed and the shell share them:
--   gopls          language server (default config from nvim-lspconfig)
--   goimports      fixes imports, then
--   gofumpt        stricter gofmt; both run on <leader>f
--   golangci-lint  linter, run through nvim-lint
--
-- See `:help lspconfig-all` (gopls), and `:help conform` / `:help lint`.

vim.lsp.enable 'gopls'

require('conform').formatters_by_ft.go = { 'goimports', 'gofumpt' }

require('lint').linters_by_ft.go = { 'golangcilint' }
