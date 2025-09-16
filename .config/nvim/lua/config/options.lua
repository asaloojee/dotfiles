-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_prettier_needs_config = false

-- Enhanced indentation and formatting for JS/TS/JSX/TSX/CSS
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.indentexpr = ""

-- Tab and space settings for better JS/TS support
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true

-- Ensure proper line continuation and brace matching
vim.opt.showmatch = true
vim.opt.matchtime = 2

-- Better folding with treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""

-- Line number settings - use normal line numbers instead of relative
vim.opt.number = true
vim.opt.relativenumber = false
