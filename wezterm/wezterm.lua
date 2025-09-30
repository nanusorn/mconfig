local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = "RESIZE" -- disable the title bar but enable the resizable border
config.native_macos_fullscreen_mode = true

-- config.color_scheme = "Nord (Gogh)"
config.color_scheme = "tokyonight_night"

config.font = wezterm.font("BlexMono Nerd Font")
config.font_size = 18
config.line_height = 1.1

config.colors = {
  cursor_bg = "#7aa2f7",
  cursor_border = "#7aa2f7",
  tab_bar = {
    background = "#1a1b26",
    active_tab = {
      bg_color = "#7aa2f7",
      fg_color = "#1a1b26",
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = "#2a2e3f",
      fg_color = "#7aa2f7",
    },
    inactive_tab_hover = {
      bg_color = "#3b4261",
      fg_color = "#ffffff",
    },
  },
}

-- Pane focus aware borders
wezterm.on('update-status', function(window, pane)
  local overrides = window:get_config_overrides() or {}

  -- Get all panes and check which is active
  local active_pane = window:active_pane()
  local is_active = active_pane:pane_id() == pane:pane_id()

  if is_active then
    overrides.colors = overrides.colors or {}
    overrides.colors.split = "#7aa2f7" -- bright blue for active pane border
  end

  window:set_config_overrides(overrides)
end)

-- Set default split colors
config.colors.split = "#3b4261" -- dim gray for inactive pane borders

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 1.0,
  brightness = 0.4,
}

-- here's my leader
config.leader = {
  key = 's',
  mods = 'CTRL',
  timeout_milliseconds = 1000,
}

config.keys = {
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane {
      confirm = false,
    },
  },
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal {
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical {
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action.SendString 'clear\n'
  },
  {
    key = '%',
    mods = 'LEADER',
    action = wezterm.action.SplitHorizontal {
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = '"',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical {
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 'k',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'j',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'h',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'l',
    mods = 'LEADER',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

config.background = {
  {
    source = {
      File = "/Users/mcduck/Desktop/Others/3d-rendering-hexagonal-texture-background.jpg",
    },
    hsb = {
      hue = 1.0,
      saturation = 1.02,
      brightness = 0.25,
    },
    width = "100%",
    height = "100%",
  },
  {
    source = {
      Color = "#282c35",
    },
    width = "100%",
    height = "100%",
    opacity = 0.55,
  },
}

config.initial_cols = 300
config.initial_rows = 80

config.window_padding = {
  left = 30,
  right = 30,
  top = 10,
  bottom = 10,
}

-- window_position_left = 0
-- window_position_top = 100

return config
