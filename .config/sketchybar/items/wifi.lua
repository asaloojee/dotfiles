local colors = require("colors")
local icons = require("icons")

local connection_command = [[route get default 2>/dev/null | awk '/interface:/{print $2; exit}']]
local speed_command =
	[[iface=$(route get default 2>/dev/null | awk '/interface:/{print $2; exit}'); if [ -n "$iface" ]; then netstat -ibn | awk -v iface="$iface" '$1 == iface && $3 ~ /^<Link/ {print iface, $7, $10; exit}'; fi]]

local popup_open = false
local last_rx = nil
local last_tx = nil
local last_time = nil

local function open_wifi_settings()
	sbar.exec('open "x-apple.systempreferences:com.apple.Wi-Fi-Settings.extension"')
end

local wifi = sbar.add("item", "wifi", {
	position = "right",
	update_freq = 2,
	padding_left = 0,
	padding_right = 24,
	icon = {
		string = icons.wifi.icon,
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

local speed = sbar.add("item", "wifi.speed", {
	position = "popup." .. wifi.name,
	icon = { drawing = false },
	label = {
		string = "Sampling",
		color = colors.fg,
		padding_left = 12,
		padding_right = 12,
	},
})

local function format_rate(bytes_per_second)
	if bytes_per_second < 1024 then
		return string.format("%d B/s", bytes_per_second)
	elseif bytes_per_second < 1024 * 1024 then
		return string.format("%.1f KB/s", bytes_per_second / 1024)
	else
		return string.format("%.1f MB/s", bytes_per_second / (1024 * 1024))
	end
end

local function set_connection_style(connected)
	wifi:set({
		icon = {
			string = icons.wifi.icon,
			color = connected and colors.accent or colors.fg_secondary,
		},
	})
end

local function update_connection()
	sbar.exec(connection_command, function(result)
		set_connection_style((result or ""):match("%S+") ~= nil)
	end)
end

local function update_speed()
	sbar.exec(speed_command, function(result)
		local iface, rx_raw, tx_raw = (result or ""):match("(%S+)%s+(%d+)%s+(%d+)")

		if not iface then
			speed:set({ label = "No connection" })
			last_rx = nil
			last_tx = nil
			last_time = nil
			set_connection_style(false)
			return
		end

		local rx = tonumber(rx_raw) or 0
		local tx = tonumber(tx_raw) or 0
		local now = os.time()

		if not last_rx or not last_tx or not last_time then
			speed:set({ label = "Sampling" })
		else
			local elapsed = math.max(1, now - last_time)
			local down = math.max(0, math.floor((rx - last_rx) / elapsed))
			local up = math.max(0, math.floor((tx - last_tx) / elapsed))

			speed:set({
				label = "↓ " .. format_rate(down) .. "   ↑ " .. format_rate(up),
			})
		end

		last_rx = rx
		last_tx = tx
		last_time = now
		set_connection_style(true)
	end)
end

wifi:subscribe("routine", function()
	if popup_open then
		update_speed()
	else
		update_connection()
	end
end)

wifi:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "right" then
		open_wifi_settings()
		return
	end

	popup_open = not popup_open
	wifi:set({ popup = { drawing = popup_open } })

	if popup_open then
		last_rx = nil
		last_tx = nil
		last_time = nil
		update_speed()
	else
		update_connection()
	end
end)

wifi:subscribe("mouse.exited.global", function()
	popup_open = false
	wifi:set({ popup = { drawing = false } })
	update_connection()
end)

update_connection()

return wifi.name
