local colors = require("colors")
local icons = require("icons")

local battery = sbar.add("item", "battery", {
	position = "right",
	update_freq = 120,
	padding_left = 0,
	padding_right = 16,
	icon = {
		string = icons.battery.levels[0],
		color = colors.primary,
		padding_left = 0,
		padding_right = 8,
	},
	label = {
		color = colors.secondary,
		padding_left = 0,
		padding_right = 0,
	},
})

local function battery_level(percent)
	local rounded = math.floor((percent + 12.5) / 25) * 25
	return math.min(100, math.max(0, rounded))
end

local function is_charging(result)
	return (result or ""):match(";%s*charging;") ~= nil
end

local function battery_icon(percent, charging)
	if charging then
		return icons.battery.charging
	end

	return icons.battery.levels[battery_level(percent)] or ""
end

local function update()
	sbar.exec("pmset -g batt", function(result)
		local percent = tonumber((result or ""):match("(%d+)%%")) or 0
		local charging = is_charging(result)

		battery:set({
			icon = {
				string = battery_icon(percent, charging),
				color = colors.primary,
			},
			label = {
				string = tostring(percent) .. "%",
				color = colors.secondary,
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
