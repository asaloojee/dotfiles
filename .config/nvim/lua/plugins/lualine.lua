return {
	"nvim-lualine/lualine.nvim",

	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	opts = {
		options = {
			icons_enabled = true,
			theme = "auto",
			section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
			component_separators = { left = "|", right = "|" },
		},
		sections = {
			lualine_a = {
				{ "mode", padding = { left = 1, right = 1 }, color = { gui = "bold" } },
			},
			lualine_b = {
				{ "branch", padding = { left = 1, right = 1 }, color = { gui = "bold" } },
				{
					"diff",
					symbols = { added = "+", modified = "~", removed = "-" },
					diff_color = {
						added = { fg = "#73daca" },
						modified = { fg = "#7aa2f7" },
						removed = { fg = "#f7768e" },
					},
					padding = { left = 1, right = 1 },
				},
				{ "diagnostics", padding = { left = 1, right = 1 }, color = { gui = "bold" } },
			},
			lualine_c = {
				{ "filename", path = 0, padding = { left = 1, right = 1 } },
			},
			lualine_x = {
				{
					"encoding",
					padding = { left = 1, right = 1 },
				},
				{
					"fileformat",
					symbols = { unix = "" },
					padding = { left = 1, right = 1 },
					color = { gui = "bold" },
				},
				{
					"filetype",
					icon_only = false,
					padding = { left = 1, right = 1 },
				},
			},
			lualine_y = {
				{ "progress", padding = { left = 1, right = 1 }, color = { gui = "bold" } },
			},
			lualine_z = {
				{ "location", padding = { left = 1, right = 1 }, color = { gui = "bold" } },
			},
		},
	},
}
