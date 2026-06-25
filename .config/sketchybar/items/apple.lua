local colors = require("colors")
local icons = require("icons")

local popup_open = false

local apple = sbar.add("item", "apple", {
	position = "left",
	padding_left = 0,
	padding_right = 16,
	icon = {
		string = icons.apple,
		color = colors.accent,
		padding_left = 0,
		padding_right = 0,
	},
	label = { drawing = false },
	popup = {
		height = 34,
		background = {
			color = colors.popup.bg,
			border_color = colors.popup.border,
			border_width = 1,
			corner_radius = 10,
		},
	},
})

local function close_popup()
	popup_open = false
	apple:set({ popup = { drawing = false } })
end

local function add_menu_item(name, label, command)
	local item = sbar.add("item", "apple." .. name, {
		position = "popup." .. apple.name,
		icon = { drawing = false },
		label = {
			string = label,
			color = colors.fg,
			padding_left = 12,
			padding_right = 12,
		},
	})

	item:subscribe("mouse.clicked", function()
		close_popup()
		sbar.exec(command)
	end)
end

add_menu_item("settings", "Settings", "open -a 'System Settings'")
add_menu_item("activity", "Activity Monitor", "open -a 'Activity Monitor'")
add_menu_item(
	"lock",
	"Lock Screen",
	[["/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession" -suspend]]
)
add_menu_item("reload_bar", "Reload Bar", "sketchybar --reload")
add_menu_item("reload_aerospace", "Reload Aerospace", "aerospace reload-config")

apple:subscribe("mouse.clicked", function()
	popup_open = not popup_open
	apple:set({ popup = { drawing = popup_open } })
end)

apple:subscribe("mouse.exited.global", close_popup)

return apple.name
