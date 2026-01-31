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

-- Helper function to create a 4-pane personal workspace
local function create_personal_workspace(window, pane)
  local mux_window = window:mux_window()
  local tab = mux_window:active_tab()

  -- Close all existing panes except the first one
  local panes = tab:panes()
  for i = #panes, 2, -1 do
    panes[i]:activate()
    window:perform_action(act.CloseCurrentPane { confirm = false }, panes[i])
  end

  -- Start with the base pane (will become top pane)
  local base_pane = tab:active_pane()
  base_pane:activate()

  -- Step 1: Split vertically to create bottom pane (75% top, 25% bottom)
  base_pane:split { direction = 'Bottom', size = 0.25 }

  -- Step 2: In the bottom pane, split right to create bottom-right (50% left, 50% right)
  local bottom_pane = tab:active_pane()
  bottom_pane:split { direction = 'Right', size = 0.5 }

  -- Step 3: Go to top pane and split right to create top-right (60% left, 40% right)
  window:perform_action(act.ActivatePaneDirection 'Up', bottom_pane)
  local top_pane = tab:active_pane()
  top_pane:split { direction = 'Right', size = 0.4 }

  -- Return focus to top-left pane
  window:perform_action(act.ActivatePaneDirection 'Left', top_pane)
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
    local created_panes = {
      { pane = base_pane, info = saved_tab.panes[1] }
    }

    -- Helper function to find which pane to split from
    local function find_parent_pane(target_info, existing_panes)
      -- Check for vertical split (same left position, different top)
      for idx, entry in ipairs(existing_panes) do
        local existing_info = entry.info
        if target_info.left == existing_info.left and
            target_info.width == existing_info.width and
            target_info.top == existing_info.top + existing_info.height then
          return idx, 'Bottom'
        end
      end

      -- Check for horizontal split (same top position, different left)
      for idx, entry in ipairs(existing_panes) do
        local existing_info = entry.info
        if target_info.top == existing_info.top and
            target_info.height == existing_info.height and
            target_info.left == existing_info.left + existing_info.width then
          return idx, 'Right'
        end
      end

      -- Fallback: find best overlap match
      local best_idx = 1
      local best_overlap = 0

      for idx, entry in ipairs(existing_panes) do
        local existing_info = entry.info

        -- Calculate overlap area
        local overlap_left = math.max(target_info.left, existing_info.left)
        local overlap_top = math.max(target_info.top, existing_info.top)
        local overlap_right = math.min(
          target_info.left + target_info.width,
          existing_info.left + existing_info.width
        )
        local overlap_bottom = math.min(
          target_info.top + target_info.height,
          existing_info.top + existing_info.height
        )

        if overlap_right > overlap_left and overlap_bottom > overlap_top then
          local overlap = (overlap_right - overlap_left) * (overlap_bottom - overlap_top)
          if overlap > best_overlap then
            best_overlap = overlap
            best_idx = idx
          end
        end
      end

      -- Determine direction based on relative position
      local parent_info = created_panes[best_idx].info
      if target_info.top >= parent_info.top + parent_info.height then
        return best_idx, 'Bottom'
      else
        return best_idx, 'Right'
      end
    end

    for i = 2, #saved_tab.panes do
      local pane_info = saved_tab.panes[i]

      -- Find which pane to split from
      local parent_idx, direction = find_parent_pane(pane_info, created_panes)
      local parent_entry = created_panes[parent_idx]

      -- Calculate split size
      local size = 0.5
      if direction == 'Bottom' then
        local total_height = pane_info.height + parent_entry.info.height
        size = pane_info.height / total_height
      else -- 'Right'
        local total_width = pane_info.width + parent_entry.info.width
        size = pane_info.width / total_width
      end

      -- Split from the parent pane
      parent_entry.pane:activate()
      local new_pane = parent_entry.pane:split { direction = direction, size = size }
      table.insert(created_panes, { pane = new_pane, info = pane_info })
    end

    return true
  end

  return false
end

config.automatically_reload_config = true
config.enable_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.window_close_confirmation = 'AlwaysPrompt'
config.window_decorations = "RESIZE" -- disable the title bar but enable the resizable border
config.native_macos_fullscreen_mode = true

-- config.color_scheme = "Nord (Gogh)"
config.color_scheme = "tokyonight_night"
-- config.color_scheme = "Dracula"

config.font = wezterm.font("JetBrains Mono")
-- config.font = wezterm.font("FiraCode Nerd Font Mono")
-- config.font = wezterm.font("Menlo")
-- config.font = wezterm.font("Iosevka Term")
config.font_size = 18
config.line_height = 1.2

-- config.colors = {
--   cursor_bg = "#7aa2f7",
--   cursor_border = "#7aa2f7",
--   tab_bar = {
--     background = "#1a1b26",
--     active_tab = {
--       bg_color = "#7aa2f7",
--       fg_color = "#1a1b26",
--       intensity = "Bold",
--     },
--     inactive_tab = {
--       bg_color = "#2a2e3f",
--       fg_color = "#7aa2f7",
--     },
--     inactive_tab_hover = {
--       bg_color = "#3b4261",
--       fg_color = "#ffffff",
--     },
--   },
-- }

--
-- Start with maximized window
wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
  pane:send_text('fastfetch\n')
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
-- config.colors.split = "#3b4261" -- dim gray for inactive pane borders

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
    mods = 'SUPER',
    action = wezterm.action.CloseCurrentPane {
      confirm = false,
    },
  },
  {
    key = 'd',
    mods = 'SUPER',
    action = wezterm.action.SplitHorizontal {
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 'd',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.SplitVertical {
      domain = 'CurrentPaneDomain',
    },
  },
  {
    key = 'k',
    mods = 'SUPER',
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
  {
    key = 'p',
    mods = 'LEADER',
    action = wezterm.action_callback(function(window, pane)
      create_personal_workspace(window, pane)
      window:toast_notification('WezTerm', 'Personal workspace created!', nil, 2000)
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
    opacity = 0.05,
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
