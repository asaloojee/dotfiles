return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	cmd = "Oil",
	keys = {
		{
			"<leader>o",
			function()
				require("oil").toggle_float()
			end,
			desc = "Explorer",
		},
		{ "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
	},
	opts = {
		default_file_explorer = true,
		columns = { "icon" },
		view_options = {
			show_hidden = true,
		},
		float = {
			padding = 2,
			max_width = 100,
			max_height = 30,
		},
	},
}
