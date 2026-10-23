-- [[ Rust ]]
-- Not part of upstream kickstart. Tools come with the rustup toolchain
-- (Homebrew's rustup; zshrc puts its bin folder on PATH):
--   rust-analyzer   language server (`rustup component add rust-analyzer`, so it
--                   matches the toolchain); runs clippy for its checks
--   rustfmt         formatter on <leader>f

vim.lsp.config('rust_analyzer', {
  settings = {
    ['rust-analyzer'] = { check = { command = 'clippy' } },
  },
})

vim.lsp.enable 'rust_analyzer'

require('conform').formatters_by_ft.rust = { 'rustfmt' }
