-- [[ Markdown rendering ]]
-- Not part of upstream kickstart.
--
-- Renders headings, code blocks, tables, checkboxes and callouts in the buffer
-- (raw text comes back on the cursor line). Uses the `markdown`,
-- `markdown_inline` and `html` treesitter parsers (installed in
-- custom.plugins.treesitter), `yaml` for front matter (installed below), and
-- mini.icons for code block icons (loaded only when `vim.g.have_nerd_font`).
--
-- See `:help render-markdown` and https://github.com/MeanderingProgrammer/render-markdown.nvim

local gh = require('custom.config.pack').gh

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

-- Front matter at the top of a Markdown file is YAML
require('nvim-treesitter').install { 'yaml' }

require('render-markdown').setup {
  -- LaTeX needs the `latex` parser and `utftex` or `pylatexenc`; not set up here
  latex = { enabled = false },
}
