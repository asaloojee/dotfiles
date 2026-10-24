return {
	cmd = { "ty", "server" },
	filetypes = { "python" },
	root_markers = { "ty.toml", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	settings = {
		ty = {
			-- Keep diagnostics scoped to open files for larger projects.
			diagnosticMode = "openFilesOnly",
			-- Ruff already reports syntax errors.
			showSyntaxErrors = false,
		},
	},
}
