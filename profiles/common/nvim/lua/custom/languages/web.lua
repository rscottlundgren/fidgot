-- [[ HTML and CSS ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   html, cssls   language servers from vscode-langservers-extracted
--                 (cssls also covers SCSS and Less)
--   prettier      formatter on <leader>f

vim.lsp.enable { 'html', 'cssls' }

for _, ft in ipairs { 'html', 'css', 'scss', 'less' } do
  require('conform').formatters_by_ft[ft] = { 'prettier' }
end
