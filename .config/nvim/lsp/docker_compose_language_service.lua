return {
	cmd = { "docker-compose-langserver", "--stdio" },
	filetypes = { "yaml.docker-compose" },
	root_markers = {
		"compose.yaml",
		"compose.yml",
		"docker-compose.yaml",
		"docker-compose.yml",
		".git",
	},
	single_file_support = true,
}
