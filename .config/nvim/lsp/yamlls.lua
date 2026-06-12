return {
	cmd = { "yaml-language-server", "--stdio" },
	filetypes = { "yaml", "yaml.docker-compose" },
	root_markers = { ".git" },
	single_file_support = true,
	settings = {
		yaml = {
			validate = true,
			hover = true,
			completion = true,
		},
	},
}
