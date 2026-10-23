-- Neovim starts without errors and every plugin in the lockfile is loaded.
local t = dofile(vim.env.FIDGOT_TESTS .. '/nvim/lib.lua')

t.run(function()
  t.check(vim.v.errmsg == '', 'error during startup: ' .. vim.v.errmsg)
  local messages = vim.fn.execute 'messages'
  t.check(not messages:find 'E%d+:' and not messages:find 'Error', 'startup messages contain an error:\n' .. messages)

  local active = {}
  for _, p in ipairs(vim.pack.get()) do
    active[p.spec.name] = p.active
  end
  local lock = vim.json.decode(table.concat(t.read(vim.fn.stdpath 'config' .. '/nvim-pack-lock.json'), '\n'))
  for name in pairs(lock.plugins) do
    t.check(active[name], 'plugin in the lockfile but not loaded: ' .. name)
  end
end)
