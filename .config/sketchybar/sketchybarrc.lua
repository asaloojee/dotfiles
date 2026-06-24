local config_dir = assert(os.getenv("SBAR_CONFIG_DIR"), "SBAR_CONFIG_DIR is not set")
local module_cpath = assert(os.getenv("SBARLUA_CPATH"), "SBARLUA_CPATH is not set")

package.cpath = package.cpath .. ";" .. module_cpath
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

sbar = require("sketchybar")

sbar.begin_config()
require("init")
sbar.hotload(true)
sbar.end_config()

sbar.event_loop()
