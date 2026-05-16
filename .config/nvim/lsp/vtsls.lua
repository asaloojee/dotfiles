return {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "pnpm-lock.yaml", "package-lock.json", "yarn.lock", ".git" },
	settings = {
		typescript = {
			suggest = { autoImports = true },
			preferences = { includePackageJsonAutoImports = "on" },
		},
		javascript = {
			suggest = { autoImports = true },
			preferences = { includePackageJsonAutoImports = "on" },
		},
	},
}
