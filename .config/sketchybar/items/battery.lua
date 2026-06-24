local colors = require("colors")
local icons = require("icons")

local battery = sbar.add("item", "battery", {
	position = "right",
	update_freq = 120,
	padding_left = 0,
	padding_right = 8,
	icon = {
		string = icons.battery.levels[0],
		color = colors.green,
		padding_left = 12,
		padding_right = 4,
	},
	label = {
		color = colors.fg,
		padding_left = 4,
		padding_right = 12,
	},
	background = {
		drawing = true,
		color = colors.surface,
		corner_radius = 8,
		height = 24,
	},
})

local function battery_level(percent)
	local rounded = math.floor((percent + 12.5) / 25) * 25
	return math.min(100, math.max(0, rounded))
end

local function battery_icon(percent)
	return icons.battery.levels[battery_level(percent)] or ""
end

local function battery_color(percent)
	return percent < 20 and colors.danger or colors.green
end

local function update()
	sbar.exec("pmset -g batt", function(result)
		local percent = tonumber((result or ""):match("(%d+)%%")) or 0

		battery:set({
			icon = {
				string = battery_icon(percent),
				color = battery_color(percent),
			},
			label = {
				string = tostring(percent),
				color = colors.fg,
			},
		})
	end)
end

battery:subscribe({ "routine", "forced", "power_source_change", "system_woke" }, update)

local function open_battery_settings()
	sbar.exec('open "x-apple.systempreferences:com.apple.Battery-Settings.extension"')
end

battery:subscribe("mouse.clicked", open_battery_settings)

update()

return battery.name
