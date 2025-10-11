local wezterm = require("wezterm")
wezterm.log_error("Config Dir: " .. wezterm.config_dir)
local config = wezterm.config_builder()
local mux = wezterm.mux
local act = wezterm.action

-- Workspace persistence file
local workspace_state_file = wezterm.config_dir .. "/workspace_state.json"

-- Helper function to save workspace state
local function save_workspace_state(window)
  local workspace = {
    tabs = {}
  }

  for _, tab in ipairs(window:mux_window():tabs()) do
    local tab_info = {
      panes = {}
    }

    for _, pane_info in ipairs(tab:panes_with_info()) do
      table.insert(tab_info.panes, {
        index = pane_info.index,
        is_active = pane_info.is_active,
        is_zoomed = pane_info.is_zoomed,
        left = pane_info.left,
        top = pane_info.top,
        width = pane_info.width,
        height = pane_info.height,
        pixel_width = pane_info.pixel_width,
        pixel_height = pane_info.pixel_height,
      })
    end

    table.insert(workspace.tabs, tab_info)
  end

  -- Write to file
  local file = io.open(workspace_state_file, "w")
  if file then
    file:write(wezterm.json_encode(workspace))
    file:close()
    return true
  end
  return false
end

-- Helper function to restore workspace state
local function restore_workspace_state(window)
  local file = io.open(workspace_state_file, "r")
  if not file then
    return false
  end

  local content = file:read("*all")
  file:close()

  local success, workspace = pcall(wezterm.json_parse, content)
  if not success or not workspace then
    return false
  end

  -- Get the current tab and pane
  local mux_window = window:mux_window()
  local tab = mux_window:active_tab()

  -- Recreate the pane layout from the first saved tab
  if workspace.tabs and #workspace.tabs > 0 then
    local saved_tab = workspace.tabs[1]

    -- Sort panes by index to recreate in order
    table.sort(saved_tab.panes, function(a, b) return a.index < b.index end)

    -- Close all existing panes except the first one
    local panes = tab:panes()
    for i = #panes, 2, -1 do
      panes[i]:activate()
      window:perform_action(act.CloseCurrentPane { confirm = false }, panes[i])
    end

    -- Recreate panes based on their relative positions
    local base_pane = tab:active_pane()
    local created_panes = { base_pane }

    for i = 2, #saved_tab.panes do
      local pane_info = saved_tab.panes[i]
      local prev_pane_info = saved_tab.panes[i - 1]

      -- Determine split direction based on position
      local direction = 'Right'
      local size = 0.5

      if pane_info.top > prev_pane_info.top then
        direction = 'Bottom'
        size = pane_info.height / (pane_info.height + prev_pane_info.height)
      elseif pane_info.left > prev_pane_info.left then
        direction = 'Right'
        size = pane_info.width / (pane_info.width + prev_pane_info.width)
      end

      -- Split from the previous pane
      created_panes[i - 1]:activate()
      local new_pane = created_panes[i - 1]:split { direction = direction, size = size }
      table.insert(created_panes, new_pane)
    end

    return true
  end

  return false
end

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

-- Start with maximized window
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
  pane:send_text('neofetch\n')
end)

-- Fix window sizing after waking from sleep on macOS
wezterm.on('window-focus-changed', function(window, pane)
  if window:is_focused() then
    -- Force a resize calculation by toggling the pane zoom state twice
    window:perform_action(wezterm.action.TogglePaneZoomState, pane)
    window:perform_action(wezterm.action.TogglePaneZoomState, pane)
  end
end)

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
  brightness = 0.75,
}

-- here's my leader
config.leader = {
  key = 's',
  mods = 'CTRL',
  timeout_milliseconds = 1000,
}

config.keys = {
  {
    key = "Enter",
    mods = "SHIFT",
    action = wezterm.action {
      SendString = "\x1b\r",
    }
  },
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
  -- Workspace save/restore
  {
    key = 's',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      if save_workspace_state(window) then
        window:toast_notification('WezTerm', 'Workspace saved!', nil, 2000)
      else
        window:toast_notification('WezTerm', 'Failed to save workspace', nil, 2000)
      end
    end),
  },
  {
    key = 'r',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      if restore_workspace_state(window) then
        window:toast_notification('WezTerm', 'Workspace restored!', nil, 2000)
      else
        window:toast_notification('WezTerm', 'No saved workspace found', nil, 2000)
      end
    end),
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
