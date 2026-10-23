-- [[ Java ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   openjdk              the JDK (keg-only; zshrc puts it on PATH and sets JAVA_HOME)
--   jdtls                Eclipse JDT language server (default config from
--                        nvim-lspconfig; slow to start on a new project)
--   google-java-format   formatter on <leader>f

vim.lsp.enable 'jdtls'

require('conform').formatters_by_ft.java = { 'google-java-format' }
