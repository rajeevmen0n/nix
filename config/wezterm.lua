-- Pull in the wezterm API
local wezterm = require("wezterm")

-- config
local config = wezterm.config_builder()

config.front_end = "WebGpu"

config.font = wezterm.font("JetBrains Mono")
config.font_size = 12

config.enable_tab_bar = true
--config.window_decorations = "RESIZE"

config.window_background_opacity = 0.9
config.max_fps = 240

--colorscheme
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#000000"
custom.tab_bar.background = "#040404"
custom.tab_bar.inactive_tab.bg_color = "#0f0f0f"
custom.tab_bar.new_tab.bg_color = "#080808"
config.color_schemes = {
    ["OLEDppuccin"] = custom,
}
config.color_scheme = "OLEDppuccin"

return config