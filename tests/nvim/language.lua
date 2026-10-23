-- A language module works on a fixture file: its language server attaches,
-- reports the expected diagnostic, and the formatter (conform, as on
-- <leader>f) produces the expected result. Set by languages_slow_test.go:
--   FIDGOT_FILE       the fixture file to open
--   FIDGOT_CLIENT     language server that should attach
--   FIDGOT_DIAG       text an expected diagnostic contains (unset: none)
--   FIDGOT_SAVE       set: save the file (every 2s until the diagnostic shows)
--                     for linters that run on save; texlab ignores a save
--                     made the moment it attaches
--   FIDGOT_FORMATTED  file with the expected formatter output
--   FIDGOT_WAIT       how long to wait for the server, in milliseconds
local t = dofile(vim.env.FIDGOT_TESTS .. '/nvim/lib.lua')

local function describe_diagnostics()
  local lines = {}
  for _, d in ipairs(vim.diagnostic.get(0)) do
    table.insert(lines, ('  %s: %s'):format(d.source or '?', d.message))
  end
  return #lines > 0 and table.concat(lines, '\n') or '  (none)'
end

t.run(function()
  local wait = tonumber(vim.env.FIDGOT_WAIT)
  vim.cmd.edit(vim.env.FIDGOT_FILE)

  local name = vim.env.FIDGOT_CLIENT
  local attached = vim.wait(wait, function()
    local client = vim.lsp.get_clients({ bufnr = 0, name = name })[1]
    return client ~= nil and client.initialized
  end, 100)
  if not attached then
    local names = vim.tbl_map(function(c) return c.name end, vim.lsp.get_clients { bufnr = 0 })
    t.check(false, ('%s did not attach to %s (filetype %s); attached: %s'):format(name, vim.fn.expand '%:t', vim.bo.filetype, vim.inspect(names)))
    return
  end

  local diag = vim.env.FIDGOT_DIAG
  if diag then
    local function has_diag()
      for _, d in ipairs(vim.diagnostic.get(0)) do
        if d.message:find(diag, 1, true) then return true end
      end
      return false
    end
    local found, deadline = false, vim.uv.now() + wait
    repeat
      if vim.env.FIDGOT_SAVE then vim.cmd 'silent write' end
      found = vim.wait(2000, has_diag, 100)
    until found or vim.uv.now() > deadline
    t.check(found, ('no diagnostic containing %q; got:\n%s'):format(diag, describe_diagnostics()))
  end

  require('conform').format { bufnr = 0, async = false, timeout_ms = wait }
  local got = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local want = t.read(vim.env.FIDGOT_FORMATTED)
  t.check(vim.deep_equal(got, want), ('formatted:\n%s\nwant:\n%s'):format(table.concat(got, '\n'), table.concat(want, '\n')))
end)
