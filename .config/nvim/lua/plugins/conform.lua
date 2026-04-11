return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format()
			end,
		},
	},
	opts = {
		format_on_save = { timeout_ms = 3000, lsp_format = "fallback" },
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format" },
			rust = { "rustfmt" },
		},
		formatters = {
			rustfmt = {
				prepend_args = { "--config", "tab_spaces=2" },
			},
		},
	},
}
