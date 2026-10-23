-- [[ Linting ]]
-- Not part of upstream kickstart. Based on lua/kickstart/plugins/lint.lua, which
-- uses the older `markdownlint` CLI.
--
-- Markdown is linted with markdownlint-cli2 (installed with Homebrew), using
-- the repo's .markdownlint-cli2.jsonc when the file is inside the repo.
--
-- See `:help lint` and https://github.com/mfussenegger/nvim-lint

local gh = require('custom.config.pack').gh

vim.pack.add { gh 'mfussenegger/nvim-lint' }

local lint = require 'lint'
lint.linters_by_ft = {
  markdown = { 'markdownlint-cli2' },
}

-- Lint when entering a buffer, after saving and when leaving insert mode.
-- Only in buffers you can modify, to skip LSP hover pop-ups (which are Markdown).
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('custom-lint', { clear = true }),
  callback = function()
    if vim.bo.modifiable then lint.try_lint() end
  end,
})
