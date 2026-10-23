-- Saving a Lua or Markdown file formats it (conform's format_on_save).
-- FIDGOT_TMP holds a copy of the config's .stylua.toml, so stylua formats the
-- way it does inside the config.
local t = dofile(vim.env.FIDGOT_TESTS .. '/nvim/lib.lua')

local cases = {
  { file = 'format.lua', before = { 'local x = {1,2,   3}', 'print("hi")' }, after = { 'local x = { 1, 2, 3 }', "print 'hi'" } },
  { file = 'format.md', before = { '#  Title', '*  item' }, after = { '# Title', '', '- item' } },
}

t.run(function()
  for _, c in ipairs(cases) do
    local path = vim.env.FIDGOT_TMP .. '/' .. c.file
    vim.fn.writefile(c.before, path)
    vim.cmd.edit(path)
    vim.cmd.write()
    local got = t.read(path)
    t.check(vim.deep_equal(got, c.after), ('%s after save:\n%s\nwant:\n%s'):format(c.file, table.concat(got, '\n'), table.concat(c.after, '\n')))
    vim.cmd 'bwipeout!'
  end
end)
