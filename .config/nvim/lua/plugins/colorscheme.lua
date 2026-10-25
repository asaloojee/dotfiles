return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			style = "night",
			cache = false,
			transparent = false,
			styles = {
				sidebars = "normal",
				floats = "normal",
				comments = { italic = true },
				keywords = { italic = true, bold = true },
				functions = { bold = true },
			},
			on_colors = function(colors)
				-- Re-read the generated palette on every colorscheme reload.
				local palette = vim.json.decode(
					table.concat(vim.fn.readfile(vim.fn.stdpath("config") .. "/tokyonight-night.json"), "\n")
				)
				for name, value in pairs(palette) do
					colors[name] = vim.deepcopy(value)
				end
			end,
			on_highlights = function(hl, colors)
				-- Keep floating cards distinct from the editor backdrop.
				hl.FloatBorder = { fg = colors.fg_gutter, bg = colors.bg_float }
				hl.FloatTitle = { fg = colors.blue, bg = colors.bg_float, bold = true }
			end,
		})
		vim.cmd.colorscheme("tokyonight-night")
	end,
}
