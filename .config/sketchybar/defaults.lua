local colors = require("colors")

sbar.default({
	updates = "when_shown",
	icon = {
		font = "SF Symbols:Regular:16.0",
		color = colors.fg,
		padding_left = 0,
		padding_right = 0,
	},
	label = {
		font = "JetBrains Mono:SemiBold:16.0",
		color = colors.fg,
		padding_left = 0,
		padding_right = 0,
	},
	background = {
		border_width = 0,
	},
	padding_left = 0,
	padding_right = 0,
})
