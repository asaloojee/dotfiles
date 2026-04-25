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
			javascript = { "biome" },
			typescript = { "biome" },
			javascriptreact = { "biome" },
			typescriptreact = { "biome" },
			css = { "biome" },
			json = { "biome" },
			graphql = { "biome" },
			svelte = { "biome" },
		},
	},
}
