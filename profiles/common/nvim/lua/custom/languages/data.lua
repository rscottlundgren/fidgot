-- [[ JSON, YAML and TOML ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   jsonls     JSON language server (vscode-langservers-extracted)
--   yamlls     yaml-language-server
--   taplo      TOML language server and formatter
--   prettier   formatter for JSON and YAML on <leader>f (JSONC keeps its
--              trailing commas; see the repo's .prettierrc)
-- Schemas for common files (package.json, tsconfig.json, GitHub workflows,
-- ...) come from SchemaStore.nvim, so the servers validate and complete them.

local gh = require('custom.config.pack').gh

vim.pack.add { gh 'b0o/SchemaStore.nvim' }

-- Zed's settings files allow comments and trailing commas
vim.filetype.add {
  pattern = {
    ['.*/zed/settings%.json'] = 'jsonc',
    ['.*/%.zed/settings%.json'] = 'jsonc',
  },
}

-- jsonls warns about every trailing comma in JSONC; Zed's settings use them
-- throughout, so drop that one message for jsonc buffers. Diagnostics arrive
-- by push or pull depending on the server, so filter both.
local function without_trailing_comma(uri, diagnostics)
  if vim.bo[vim.uri_to_bufnr(uri)].filetype ~= 'jsonc' then return diagnostics end
  return vim.tbl_filter(function(d) return d.message ~= 'Trailing comma' end, diagnostics)
end

vim.lsp.config('jsonls', {
  settings = {
    json = { schemas = require('schemastore').json.schemas(), validate = { enable = true } },
  },
  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx)
      if result then result.diagnostics = without_trailing_comma(result.uri, result.diagnostics) end
      return vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
    end,
    ['textDocument/diagnostic'] = function(err, result, ctx)
      if result and result.items then result.items = without_trailing_comma(ctx.params.textDocument.uri, result.items) end
      return vim.lsp.diagnostic.on_diagnostic(err, result, ctx)
    end,
  },
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      -- Use SchemaStore.nvim's catalog instead of the server's built-in download
      schemaStore = { enable = false, url = '' },
      schemas = require('schemastore').yaml.schemas(),
    },
  },
})

vim.lsp.enable { 'jsonls', 'yamlls', 'taplo' }

local conform = require 'conform'
for _, ft in ipairs { 'json', 'jsonc', 'yaml' } do
  conform.formatters_by_ft[ft] = { 'prettier' }
end
conform.formatters_by_ft.toml = { 'taplo' }
