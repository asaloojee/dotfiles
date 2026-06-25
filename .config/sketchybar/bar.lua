local colors = require("colors")

sbar.bar({
	position = "top",
	height = 34,
	color = colors.bar_bg,
	corner_radius = 0,
	blur_radius = 20,
	shadow = false,
	sticky = true,
	padding_left = 16,
	padding_right = 16,
	-- margin = 12,
	-- y_offset = 4,
})
