return {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
	root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", ".git" },
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
