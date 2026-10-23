-- Shared by the Neovim test scripts, which nvim_test.go runs in headless
-- Neovim with the repo's config. A script calls check() for each expectation
-- and finish() at the end; finish() exits non-zero if any check failed, and
-- the FAIL lines on stdout end up in the Go test's output.

local M = { failed = false }

function M.check(ok, msg)
  if not ok then
    M.failed = true
    io.stdout:write('FAIL: ' .. msg .. '\n')
  end
end

-- Every process below pid, children after their own children: a process
-- whose parent dies is handed to launchd and can't be found from here.
local function descendants(pid, acc)
  for _, child in ipairs(vim.api.nvim_get_proc_children(pid)) do
    descendants(child, acc)
    table.insert(acc, child)
  end
  return acc
end

-- Kill every process Neovim started (the language servers and what they run,
-- like zls's zig) and wait for them to exit, then quit. Neovim starts servers
-- detached, so they'd outlive it, and some keep writing to the cache dir the
-- Go test deletes. Nothing here needs a clean server shutdown, and a server
-- still starting up ignores a polite stop.
function M.finish()
  local pids = descendants(vim.fn.getpid(), {})
  for _, pid in ipairs(pids) do
    vim.uv.kill(pid, 'sigkill')
  end
  vim.wait(5000, function()
    return vim.iter(pids):all(function(pid) return vim.uv.kill(pid, 0) ~= 0 end)
  end, 20)
  vim.cmd(M.failed and 'cquit 1' or 'qall!')
end

-- Run fn, turning an error into a failed check so finish() still runs.
function M.run(fn)
  local ok, err = xpcall(fn, debug.traceback)
  M.check(ok, tostring(err))
  M.finish()
end

-- Contents of a file as a list of lines.
function M.read(path) return vim.fn.readfile(path) end

return M
