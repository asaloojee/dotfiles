local colors = require("colors")
local icons = require("icons")

local status_command =
	[[app_pid="$(pgrep -x KeepingYouAwake | head -n 1)"; if [ -n "$app_pid" ] && pgrep -x -P "$app_pid" caffeinate >/dev/null; then echo active; else echo inactive; fi]]
local toggle_command = [[open -g "keepingyouawake:///toggle"]]

local keepingyouawake = sbar.add("item", "keepingyouawake", {
	position = "right",
	update_freq = 5,
	padding_left = 0,
	padding_right = 8,
	icon = {
		string = icons.keepingyouawake.icon,
		color = colors.fg_secondary,
		padding_left = 12,
		padding_right = 12,
	},
	label = { drawing = false },
	background = {
		drawing = true,
		color = colors.surface,
		corner_radius = 8,
		height = 24,
	},
})

local function set_status(active)
	keepingyouawake:set({
		icon = {
			string = icons.keepingyouawake.icon,
			color = active and colors.warning or colors.fg_secondary,
		},
	})
end

local function is_active(result)
	return (result or ""):match("^%s*(.-)%s*$") == "active"
end

local function update()
	sbar.exec(status_command, function(result)
		set_status(is_active(result))
	end)
end

keepingyouawake:subscribe({ "routine", "forced", "system_woke" }, update)

keepingyouawake:subscribe("mouse.clicked", function()
	sbar.exec(toggle_command, function()
		sbar.exec("sleep 0.2; " .. status_command, function(result)
			set_status(is_active(result))
		end)
	end)
end)

update()

return keepingyouawake.name
