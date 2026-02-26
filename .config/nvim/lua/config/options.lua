-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Use prettier even without a project config file
vim.g.lazyvim_prettier_needs_config = false

-- Stay in the directory where nvim was opened
vim.g.root_spec = { "cwd" }

-- Treesitter folding, all folds open by default
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""

-- Absolute line numbers instead of relative
vim.opt.number = true
vim.opt.relativenumber = false

-- Don't update diagnostics while typing in insert mode
vim.diagnostic.config({ update_in_insert = false })
