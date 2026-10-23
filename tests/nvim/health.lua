-- :checkhealth kickstart reports no errors.
local t = dofile(vim.env.FIDGOT_TESTS .. '/nvim/lib.lua')

t.run(function()
  vim.cmd 'checkhealth kickstart'
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  t.check(#lines > 1, 'checkhealth kickstart printed nothing')
  for _, line in ipairs(lines) do
    t.check(not line:find 'ERROR', 'checkhealth kickstart: ' .. line)
  end
end)
