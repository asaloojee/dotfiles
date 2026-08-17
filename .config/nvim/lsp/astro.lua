local typescript = require("config.typescript")

return {
	cmd = { "astro-ls", "--stdio" },
	cmd_env = {
		NODE_PATH = typescript.get_node_path(),
	},
	filetypes = { "astro" },
	root_markers = { "astro.config.mjs", "astro.config.ts", "package.json", ".git" },
	init_options = {
		typescript = {
			tsdk = typescript.get_tsdk(),
		},
	},
}
