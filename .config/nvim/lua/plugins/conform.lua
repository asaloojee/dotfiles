return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	keys = {
		{
			"<leader>cf",
			function()
				require("conform").format({ lsp_format = "fallback" })
			end,
		},
	},
	opts = {
		format_on_save = function(bufnr)
			local ft = vim.bo[bufnr].filetype
			if ft == "scss" or ft == "vue" then
				return nil
			end
			return { timeout_ms = 3000, lsp_format = "fallback" }
		end,
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
			vue = { "prettier" },
			-- Use LSP formatting for framework files (Astro/Svelte)
			html = { "biome_html" },
		},
		formatters = {
			biome_html = {
				inherit = "biome",
				append_args = { "--html-formatter-enabled=true" },
			},
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
	},
}
