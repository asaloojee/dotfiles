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
			local filetype = vim.bo[bufnr].filetype
			if filetype == "vue" or filetype == "scss" then
				return nil
			end

			return { timeout_ms = 3000, lsp_format = "fallback" }
		end,
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "ruff_format" },
			rust = { "rustfmt" },
			javascript = { "oxfmt" },
			typescript = { "oxfmt" },
			javascriptreact = { "oxfmt" },
			typescriptreact = { "oxfmt" },
			vue = { "oxfmt" },
			-- Oxfmt currently rejects .svelte via --stdin-filepath; use the Svelte LSP on save.
			svelte = { lsp_format = "fallback" },
			css = { "oxfmt" },
			scss = { "oxfmt" },
			less = { "oxfmt" },
			html = { "oxfmt" },
			json = { "oxfmt" },
			jsonc = { "oxfmt" },
			yaml = { "oxfmt" },
			["yaml.docker-compose"] = { "oxfmt" },
			markdown = { "oxfmt" },
			["markdown.mdx"] = { "oxfmt" },
			graphql = { "oxfmt" },
			toml = { "oxfmt" },
			-- Astro is intentionally left to the project Astro LSP; Oxfmt does not support .astro yet.
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
	},
}
