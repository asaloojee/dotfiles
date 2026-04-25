return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
	config = function(_, opts)
		-- Tokyo Night git colors
		vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#9ece6a" })
		vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#7aa2f7" })
		vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#f7768e" })
		vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = "#e0af68" })
		vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = "#565f89" })
		require("gitsigns").setup(opts)
	end,
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "▁" },
			topdelete = { text = "▁" },
			changedelete = { text = "▁" },
			untracked = { text = "▎" },
		},
		on_attach = function(buf)
			local gs = require("gitsigns")
			local map = function(mode, keys, func, desc)
				vim.keymap.set(mode, keys, func, { buffer = buf, desc = desc })
			end
			map("n", "]c", function()
				if vim.wo.diff then
					return "]c"
				end
				vim.schedule(function()
					gs.next_hunk()
				end)
				return "<Ignore>"
			end, "Next hunk")
			map("n", "[c", function()
				if vim.wo.diff then
					return "[c"
				end
				vim.schedule(function()
					gs.prev_hunk()
				end)
				return "<Ignore>"
			end, "Prev hunk")
			map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
			map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
			map("n", "<leader>hb", gs.blame_line, "Blame line")
		end,
	},
}
