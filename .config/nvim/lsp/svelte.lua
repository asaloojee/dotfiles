local typescript = require("config.typescript")

return {
	cmd = { "svelteserver", "--stdio" },
	filetypes = { "svelte" },
	root_markers = { "svelte.config.js", "svelte.config.ts", "package.json", ".git" },
	init_options = {
		typescript = {
			tsdk = typescript.get_tsdk(),
		},
	},
}
