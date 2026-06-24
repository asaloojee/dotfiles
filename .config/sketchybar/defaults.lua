local colors = require("colors")

sbar.default({
	updates = "when_shown",
	icon = {
		font = "JetBrainsMono Nerd Font:Bold:16.0",
		color = colors.fg,
		padding_left = 4,
		padding_right = 4,
	},
	label = {
		font = "JetBrainsMono Nerd Font:Bold:14.0",
		color = colors.fg,
		padding_left = 4,
		padding_right = 4,
	},
	background = {
		border_width = 0,
	},
	padding_left = 2,
	padding_right = 2,
})
