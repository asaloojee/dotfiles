return {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
	on_attach = function(client)
		-- Prefer ty for documentation; Ruff handles linting and code actions.
		client.server_capabilities.hoverProvider = false
	end,
}
