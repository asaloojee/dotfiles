return {
	"saghen/blink.cmp",
	event = "InsertEnter",
	version = "*",
	opts = {
		keymap = {
			["<CR>"] = { "accept", "fallback" },
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
		},
		completion = {
			documentation = { auto_show = true },
		},
		sources = {
			providers = {
				snippets = { score_offset = -10, min_keyword_length = 3 },
			},
		},
	},
}
