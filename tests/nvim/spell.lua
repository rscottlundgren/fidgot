-- Spell checking is on for prose and off for code.
local t = dofile(vim.env.FIDGOT_TESTS .. '/nvim/lib.lua')

t.run(function()
  local want = { md = true, txt = true, tex = true, lua = false, sh = false }
  for ext, on in pairs(want) do
    vim.cmd.edit(vim.env.FIDGOT_TMP .. '/spell.' .. ext)
    t.check(vim.wo.spell == on, ('spell is %s for .%s (filetype %s), want %s'):format(vim.wo.spell, ext, vim.bo.filetype, on))
  end
end)
