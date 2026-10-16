return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			style = "night",
			transparent = false,
			styles = {
				sidebars = "normal",
				floats = "normal",
				comments = { italic = true },
				keywords = { italic = true, bold = true },
				functions = { bold = true },
			},
			on_highlights = function(hl, colors)
				-- Keep floating cards distinct from the editor backdrop.
				hl.FloatBorder = { fg = colors.fg_gutter, bg = colors.bg_float }
				hl.FloatTitle = { fg = colors.blue, bg = colors.bg_float, bold = true }
			end,
		})
		vim.cmd.colorscheme("tokyonight-night")
	end,
}
