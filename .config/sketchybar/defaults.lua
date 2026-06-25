local colors = require("colors")

sbar.default({
	updates = "when_shown",
	icon = {
		font = "SF Pro:Bold:14.0",
		color = colors.fg_muted,
		padding_left = 0,
		padding_right = 0,
	},
	label = {
		font = "JetBrains Mono:Medium:16.0",
		color = colors.fg_muted,
		padding_left = 0,
		padding_right = 0,
	},
	background = {
		border_width = 0,
	},
	padding_left = 0,
	padding_right = 0,
})
