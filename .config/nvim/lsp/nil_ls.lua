return {
	cmd = { "nil" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", "shell.nix", "default.nix", ".git" },
	single_file_support = true,
	settings = {
		["nil"] = {
			formatting = {
				command = { "alejandra" },
			},
		},
	},
}
