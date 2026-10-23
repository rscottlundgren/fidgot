-- [[ Spell checking ]]
-- Not part of upstream kickstart.
--
-- On for prose: Markdown, git commit messages, LaTeX and plain text.
--   ]s / [s   next / previous misspelling
--   z=        suggestions
--   zg / zw   add the word under the cursor to the word list / mark it wrong
--
-- The word list is spell/en.utf-8.add in this config folder, tracked in git.
-- Neovim reads a compiled copy (en.utf-8.add.spl, not tracked); rebuild it
-- whenever it's missing or older than the word list (e.g. after `git pull`).

local spellfile = vim.fn.stdpath 'config' .. '/spell/en.utf-8.add'
vim.fn.mkdir(vim.fs.dirname(spellfile), 'p') -- zg fails if the folder doesn't exist
vim.o.spellfile = spellfile
vim.o.spelllang = 'en'

local function rebuild_if_stale()
  local add, spl = vim.uv.fs_stat(spellfile), vim.uv.fs_stat(spellfile .. '.spl')
  if add and (not spl or spl.mtime.sec < add.mtime.sec) then vim.cmd('silent mkspell! ' .. vim.fn.fnameescape(spellfile)) end
end

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Spell check prose',
  group = vim.api.nvim_create_augroup('custom-spell', { clear = true }),
  pattern = { 'markdown', 'gitcommit', 'tex', 'text' },
  callback = function()
    rebuild_if_stale()
    vim.opt_local.spell = true
  end,
})
