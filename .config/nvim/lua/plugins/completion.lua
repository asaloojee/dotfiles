return {
	"saghen/blink.cmp",
	event = "InsertEnter",
	version = "*",
	opts = {
		keymap = {
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
		},
		completion = {
			menu = {
				border = "rounded",
				scrollbar = false,
				draw = {
					columns = {
						{ "label", "label_description", gap = 1 },
						{ "kind" },
						{ "source_name" },
					},
					components = {
						label = { width = { fill = true, max = 44 } },
						source_name = { width = { max = 18 } },
					},
				},
			},
			documentation = {
				auto_show = true,
				window = {
					border = "rounded",
					max_width = 88,
					max_height = 20,
				},
			},
		},
		sources = {
			default = { "lsp", "snippets", "buffer", "path" },
			providers = {
				lsp = { fallbacks = {} },
				path = { fallbacks = {}, score_offset = 0 },
				snippets = { min_keyword_length = 0, score_offset = 0 },
				buffer = { score_offset = 0 },
			},
		},
	},
	config = function(_, opts)
		require("blink.cmp").setup(opts)

		local menu = vim.api.nvim_get_hl(0, { name = "Pmenu", link = false })
		local float_border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })

		vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "Pmenu" })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = menu.fg, bg = "NONE" })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { link = "Visual" })
		vim.api.nvim_set_hl(0, "BlinkCmpDoc", { link = "NormalFloat" })
		vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = float_border.fg, bg = "NONE" })
	end,
}
