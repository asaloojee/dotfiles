return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	keys = {
		{
			"<leader>cf",
			function()
				local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
				if ft == "vue" then
					vim.notify("Vue formatting is disabled (no working formatter configured)", vim.log.levels.WARN)
					return
				end
				require("conform").format({ lsp_format = "fallback" })
			end,
		},
	},
	opts = {
		format_on_save = function(bufnr)
			if vim.bo[bufnr].filetype == "vue" then
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
