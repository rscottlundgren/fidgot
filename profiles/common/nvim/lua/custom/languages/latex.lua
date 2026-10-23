-- [[ LaTeX ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   texlab    language server: completion, references, build with latexmk
--             (:LspTexlabBuild), forward search to Skim (:LspTexlabForward),
--             and chktex warnings when a file is saved
--   tex-fmt   formatter on <leader>f, 2-space indent unless the project has an
--             .editorconfig
-- From MacTeX (cask "mactex"): latexmk, chktex. Skim is cask "skim".
--
-- MacTeX's latexindent isn't used: it needs Perl modules macOS's system Perl
-- doesn't have.

-- A .tex file is LaTeX (filetype tex), even before it has anything in it that
-- says so; otherwise new files get plaintex and miss spell checking and tex-fmt
vim.g.tex_flavor = 'latex'

vim.lsp.config('texlab', {
  settings = {
    texlab = {
      build = {
        executable = 'latexmk',
        args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
        onSave = false,
        forwardSearchAfter = false,
      },
      forwardSearch = {
        executable = '/Applications/Skim.app/Contents/SharedSupport/displayline',
        args = { '-g', '%l', '%p', '%f' }, -- -g: keep Skim in the background
      },
      chktex = { onOpenAndSave = true, onEdit = false },
    },
  },
})

vim.lsp.enable 'texlab'

-- conform's own tex-fmt args follow the buffer's 'expandtab', which is off
-- (tabs) unless an .editorconfig turns it on; always use 2 spaces instead,
-- unless the project has an .editorconfig, which Neovim applies to the buffer.
local tex_fmt = require 'conform.formatters.tex-fmt'
require('conform').formatters['tex-fmt'] = {
  args = function(self, ctx)
    if vim.fs.find('.editorconfig', { path = ctx.dirname, upward = true })[1] then return tex_fmt.args(self, ctx) end
    return { '--stdin', '--tabsize', '2' }
  end,
}
require('conform').formatters_by_ft.tex = { 'tex-fmt' }
