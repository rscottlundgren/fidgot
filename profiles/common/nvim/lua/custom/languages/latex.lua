-- [[ LaTeX ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   texlab    language server: completion, references, build with latexmk
--             (:LspTexlabBuild), forward search to Skim (:LspTexlabForward),
--             and chktex warnings when a file is saved
--   tex-fmt   formatter on <leader>f
-- From MacTeX (cask "mactex"): latexmk, chktex. Skim is cask "skim".
--
-- MacTeX's latexindent isn't used: it needs Perl modules macOS's system Perl
-- doesn't have.

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

require('conform').formatters_by_ft.tex = { 'tex-fmt' }
