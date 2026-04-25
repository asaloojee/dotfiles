vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Options
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"

-- Cursor: replace the block with a thick bottom bar while waiting for a motion
-- (e.g. after `d`, `c`, `y`) so operator-pending mode is visually obvious.
vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

-- Indentation: 4 spaces everywhere
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- Diagnostics
vim.diagnostic.config({
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticError",
			[vim.diagnostic.severity.WARN] = "DiagnosticWarn",
		},
	},
	virtual_text = {
		severity = { min = vim.diagnostic.severity.WARN },
		spacing = 4,
		prefix = " ",
	},
})

-- Treesitter folding, all folds open by default
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""

-- LSP keymaps (set only when a server attaches)
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local buf = args.buf
		local map = function(keys, func)
			vim.keymap.set("n", keys, func, { buffer = buf })
		end
		map("gd", vim.lsp.buf.definition)
		map("gr", vim.lsp.buf.references)
		map("K", vim.lsp.buf.hover)
		map("<leader>rn", vim.lsp.buf.rename)
		map("<leader>ca", vim.lsp.buf.code_action)
		map("<leader>d", vim.diagnostic.open_float)
	end,
})

-- Enable LSP servers (configs in lsp/*.lua)
vim.lsp.enable({ "rust_analyzer", "vtsls", "cssls", "cssmodules_ls", "html", "astro" })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({ spec = { { import = "plugins" } } })
