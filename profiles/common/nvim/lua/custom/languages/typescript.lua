-- [[ TypeScript and JavaScript ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   vtsls          language server for TypeScript and JavaScript (incl. JSX/TSX)
--   eslint         ESLint language server (from vscode-langservers-extracted);
--                  attaches only in projects with an ESLint config, and uses
--                  that project's own eslint package
--   prettier       formatter on <leader>f; conform prefers a project's own
--                  node_modules/.bin/prettier when there is one
--
-- Node itself comes from nvm (see the root README); pnpm from corepack.

vim.lsp.enable { 'vtsls', 'eslint' }

for _, ft in ipairs { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } do
  require('conform').formatters_by_ft[ft] = { 'prettier' }
end
