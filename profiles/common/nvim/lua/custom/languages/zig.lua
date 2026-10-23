-- [[ Zig ]]
-- Not part of upstream kickstart. Tools from Homebrew (profiles/common/Brewfile):
--   zls       language server; must be the same release as Zig (upgrade
--             both together: `brew upgrade zig zls`)
--   zig fmt   formatter on <leader>f (built into Zig; conform's `zigfmt`)
--
-- zls reports syntax errors as you type. Compile errors (types, etc.) come
-- from its build-on-save, which runs the project's `check` step; add one to
-- build.zig (zig init doesn't):
--   const exe_check = b.addExecutable(.{ .name = "check", .root_module = exe.root_module });
--   const check = b.step("check", "Check if the program compiles");
--   check.dependOn(&exe_check.step);

vim.lsp.enable 'zls'

require('conform').formatters_by_ft.zig = { 'zigfmt' }
