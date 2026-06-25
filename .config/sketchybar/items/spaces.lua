local colors = require("colors")
local icons = require("icons")

local spaces = {}
local space_names = {}
local workspace_count = 5

local function style_space(item, active)
	item:set({
		icon = {
			color = active and colors.accent or colors.fg_secondary,
		},
		background = { drawing = false },
	})
end

local function update_spaces(focused_workspace)
	focused_workspace = tostring(focused_workspace or "")

	for sid, item in pairs(spaces) do
		style_space(item, tostring(sid) == focused_workspace)
	end
end

for sid = 1, workspace_count do
	local workspace = sid
	local space = sbar.add("item", "space." .. workspace, {
		position = "left",
		icon = {
			string = tostring(workspace),
			font = "JetBrainsMono Nerd Font:Bold:16.0",
			padding_left = 8,
			padding_right = 8,
		},
		label = { drawing = false },
		padding_left = 0,
		padding_right = 0,
	})

	spaces[workspace] = space
	space_names[#space_names + 1] = space.name

	space:subscribe("mouse.clicked", function()
		sbar.exec("aerospace workspace " .. workspace)
	end)

	space:subscribe("aerospace_workspace_change", function(env)
		update_spaces(env.FOCUSED_WORKSPACE)
	end)
end

local front_app = sbar.add("item", "front_app", {
	position = "left",
	padding_left = 8,
	padding_right = 16,
	icon = {
		string = icons.front_app.chevron,
		color = colors.accent,
		padding_left = 0,
		padding_right = 16,
	},
	label = {
		color = colors.fg,
		padding_left = 0,
		padding_right = 0,
	},
})

space_names[#space_names + 1] = front_app.name

local function set_front_app(app_name)
	front_app:set({
		label = {
			string = (app_name or ""):gsub("^%s+", ""):gsub("%s+$", ""),
		},
	})
end

front_app:subscribe("front_app_switched", function(env)
	set_front_app(env.INFO)
end)

sbar.exec(
	[[lsappinfo info -only name "$(lsappinfo front)" 2>/dev/null | awk -F'"' '/LSDisplayName/ {print $4; exit}']],
	set_front_app
)

sbar.exec("aerospace list-workspaces --focused", function(focused_workspace)
	update_spaces((focused_workspace or ""):match("%S+"))
end)

return space_names
