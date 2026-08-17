local typescript = require("config.typescript")

return {
	cmd = { "vue-language-server", "--stdio" },
	filetypes = { "vue" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	single_file_support = true,
	init_options = {
		typescript = {
			tsdk = typescript.get_tsdk(),
		},
	},
}
