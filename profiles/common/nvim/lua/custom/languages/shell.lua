-- [[ Shell scripts (sh, bash) ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   bash-language-server   completion, hover; runs shellcheck itself, so
--                          shellcheck's warnings arrive as LSP diagnostics
--   shellcheck             linter (used by bash-language-server)
--   shfmt                  formatter on <leader>f, 2-space indent (Google Shell
--                          Style Guide, like the scripts here) unless the
--                          project has an .editorconfig
--
-- zsh files aren't covered: none of these tools understands zsh syntax.

vim.lsp.enable 'bashls'

-- conform's own shfmt args use the buffer's indent width (which guess-indent
-- takes from the file); always use 2 spaces instead, unless the project has an
-- .editorconfig, which shfmt reads when given no indent flag.
require('conform').formatters.shfmt = {
  args = function(_, ctx)
    local args = { '-filename', '$FILENAME' }
    if not vim.fs.find('.editorconfig', { path = ctx.dirname, upward = true })[1] then vim.list_extend(args, { '-i', '2' }) end
    return args
  end,
}
for _, ft in ipairs { 'sh', 'bash' } do
  require('conform').formatters_by_ft[ft] = { 'shfmt' }
end
