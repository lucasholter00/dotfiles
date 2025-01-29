local wezterm = require("wezterm")

--config table
local config = wezterm.config_builder()

config.font = wezterm.font("DepartureMono Nerd Font")
config.font_size = 14

--more conifg
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- config.window_decorations = "RESIZE"

config.color_scheme = 'Catppuccin Mocha'

--multiplexer
config.leader = {key = 'a', mods = 'CTRL', timeout_milliseconds = 1000}
config.keys = {

    --Splits
    {
	    mods = "LEADER",
	    key = "-",
	    action = wezterm.action.SplitVertical {domain = 'CurrentPaneDomain'},
    },
    {
	    mods = "LEADER",
	    key = "ö",
	    action = wezterm.action.SplitHorizontal {domain = 'CurrentPaneDomain'},
    },
    --maximize pane
    {
	    mods = "LEADER",
	    key = "m",
	    action = wezterm.action.TogglePaneZoomState,
    },
    --Create tab
    {
	    mods = "LEADER",
	    key = "c",
	    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
    },
    --Delete pane
    {
	    mods = "LEADER",
	    key = "x",
	    action = wezterm.action.CloseCurrentPane { confirm = true},
    },
    --Resize
    {
	    key = "h",
	    mods = "LEADER",
	    action = wezterm.action.AdjustPaneSize {'Left', 5}
    },
    {
	    key = "j",
	    mods = "LEADER",
	    action = wezterm.action.AdjustPaneSize {'Down', 5}
    },
    {
	    key = "k",
	    mods = "LEADER",
	    action = wezterm.action.AdjustPaneSize {'Up', 5}
    },
    {
	    key = "l",
	    mods = "LEADER",
	    action = wezterm.action.AdjustPaneSize {'Right', 5}
    },
    --Workspaces
    {
	    key = "s",
    mods = "LEADER",
    action = wezterm.action.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
    },
    },
    -- Tab navigator
    {
	    key = " ",
	    mods = "LEADER",
	    action = wezterm.action.ShowTabNavigator
    },
    {
	key = "w",
	mods = "LEADER",
	action = wezterm.action.PromptInputLine {
	    description = wezterm.format {
		{ Attribute = { Intensity = "Bold" } },
		{ Foreground = { AnsiColor = "Fuchsia" } },
		{ Text = "Enter name for new workspace" },
	    },
	    action = wezterm.action_callback(function(window, pane, line)
	    -- line will be `nil` if they hit escape without entering anything
	    -- An empty string if they just hit enter
	    -- Or the actual line of text they wrote
		if line then
		  window:perform_action(
		    wezterm.action.SwitchToWorkspace {
		      name = line,
		    },
		    pane
		  )
		end
	    end),
       },
    },
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "LEADER",
        action = wezterm.action.ActivateTab(i - 1),
    })
end

--Vim direction
-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
  -- this is set by the plugin, and unset on ExitPre in Neovim
  return pane:get_user_vars().IS_NVIM == 'true'
end

local direction_keys = {
  h = 'Left',
  j = 'Down',
  k = 'Up',
  l = 'Right',
}

local function split_nav(resize_or_move, key)
  return {
    key = key,
    mods = resize_or_move == 'resize' and 'META' or 'CTRL',
    action = wezterm.action_callback(function(win, pane)
      if is_vim(pane) then
        -- pass the keys through to vim/nvim
        win:perform_action({
          SendKey = { key = key, mods = resize_or_move == 'resize' and 'META' or 'CTRL' },
        }, pane)
      else
        if resize_or_move == 'resize' then
          win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
        else
          win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
        end
      end
    end),
  }
end

table.insert(config.keys, split_nav('move', 'h'))
table.insert(config.keys, split_nav('move', 'j'))
table.insert(config.keys, split_nav('move', 'k'))
table.insert(config.keys, split_nav('move', 'l'))

return config
