local function has_local_formatter(name, ctx)
	local package_files = vim.fs.find("package.json", {
		path = vim.fs.dirname(ctx.filename),
		upward = true,
		limit = math.huge,
	})

	for _, package_file in ipairs(package_files) do
		local executable = vim.fs.joinpath(vim.fs.dirname(package_file), "node_modules", ".bin", name)
		if vim.uv.fs_stat(executable) then
			return true
		end
	end

	return false
end

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
			if vim.bo[bufnr].filetype == "vue" then
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
			-- Svelte formatting needs newer/project-local Oxfmt plus the project's svelte/compiler.
			svelte = { "oxfmt_project" },
			css = { "oxfmt" },
			scss = { "oxfmt" },
			less = { "oxfmt" },
			html = { "oxfmt" },
			json = { "oxfmt" },
			jsonc = { "oxfmt" },
			yaml = { "oxfmt" },
			markdown = { "oxfmt" },
			["markdown.mdx"] = { "oxfmt" },
			graphql = { "oxfmt" },
			toml = { "oxfmt" },
			-- Astro is intentionally left to the project Astro LSP; Oxfmt does not support .astro yet.
		},
		formatters = {
			oxfmt_project = {
				inherit = "oxfmt",
				condition = function(_, ctx)
					return has_local_formatter("oxfmt", ctx)
				end,
			},
		},
		default_format_opts = {
			lsp_format = "fallback",
		},
	},
}
