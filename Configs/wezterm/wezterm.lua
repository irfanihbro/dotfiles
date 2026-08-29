local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- =============================================
-- 1. Appearance & Theme
-- =============================================
config.color_scheme = 'Catppuccin Mocha'

config.font =
  -- wezterm.font('JetBrains Mono', { weight = 'Regular', italic = false })
  wezterm.font('Google Sans Code NF', { weight = 'Regular', italic = false })
config.font_size = 14.0

config.window_decorations = "RESIZE"
config.window_padding = {
  left = 28,
  right = 28,
  top = 20,
  bottom = 20,
}

config.initial_cols = 140
config.initial_rows = 35

-- =============================================
-- 2. Tab Bar
-- =============================================
config.enable_tab_bar = false
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.show_tab_index_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

-- =============================================
-- 3. Pane & Window Behavior
-- =============================================
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.7,
}

config.hide_tab_bar_if_only_one_tab = false
config.audible_bell = "Disabled"

-- =============================================
-- 4. Keybindings (Essential + Tmux-like)
-- =============================================
local act = wezterm.action

config.keys = {
  -- Quick config reload
  { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },

  -- Pane management (like tmux)
  { key = "v", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "h", mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },

  -- Navigate panes
  { key = "LeftArrow",  mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Left" },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Right" },
  { key = "UpArrow",    mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Up" },
  { key = "DownArrow",  mods = "CTRL|SHIFT", action = act.ActivatePaneDirection "Down" },

  -- Resize panes
  { key = "LeftArrow",  mods = "CTRL|ALT", action = act.AdjustPaneSize { "Left", 3 } },
  { key = "RightArrow", mods = "CTRL|ALT", action = act.AdjustPaneSize { "Right", 3 } },
  { key = "UpArrow",    mods = "CTRL|ALT", action = act.AdjustPaneSize { "Up", 3 } },
  { key = "DownArrow",  mods = "CTRL|ALT", action = act.AdjustPaneSize { "Down", 3 } },

  -- Tabs
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab "CurrentPaneDomain" },
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

  -- Copy & Paste
  { key = "c", mods = "CTRL", action = act.CopyTo "ClipboardAndPrimarySelection" },
  { key = "v", mods = "CTRL", action = act.PasteFrom "Clipboard" },
}

-- =============================================
-- 5. Mouse bindings
-- =============================================
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom "Clipboard",
  },
}

-- =============================================
-- 6. Misc
-- =============================================
config.automatically_reload_config = true
config.default_cursor_style = 'SteadyBar'
config.cursor_thickness = "1.5"

-- Performance
config.max_fps = 120
config.animation_fps = 60

return config
