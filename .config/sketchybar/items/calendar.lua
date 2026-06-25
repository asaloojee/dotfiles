local colors = require("colors")
local icons = require("icons")

local calendar = sbar.add("item", "calendar", {
	position = "right",
	update_freq = 30,
	padding_left = 0,
	padding_right = 0,
	icon = {
		string = icons.calendar,
		color = colors.accent,
		padding_left = 0,
		padding_right = 8,
	},
	label = {
		color = colors.fg,
		padding_left = 0,
		padding_right = 0,
	},
})

local function update()
	calendar:set({ label = os.date("%a %b %d %H:%M") })
end

calendar:subscribe({ "routine", "forced", "system_woke" }, update)

local function open_calendar()
	sbar.exec("open -a Calendar")
end

calendar:subscribe("mouse.clicked", open_calendar)

update()

return calendar.name
