-- [[ Python ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   basedpyright   type checking, completion, hover (Pyright fork)
--   ruff           lint diagnostics and fixes through its language server, and
--                  formatting on <leader>f (organize imports, then format)
--
-- Each tool keeps to its job, as Ruff's docs recommend: basedpyright leaves
-- import sorting to Ruff, and Ruff leaves hover to basedpyright.

vim.lsp.config('basedpyright', {
  settings = {
    basedpyright = {
      disableOrganizeImports = true,
      -- basedpyright's own default ('recommended') is strict; 'standard' is Pyright's default
      analysis = { typeCheckingMode = 'standard' },
    },
  },
})

vim.lsp.config('ruff', {
  on_attach = function(client) client.server_capabilities.hoverProvider = false end,
})

vim.lsp.enable { 'basedpyright', 'ruff' }

require('conform').formatters_by_ft.python = { 'ruff_organize_imports', 'ruff_format' }
