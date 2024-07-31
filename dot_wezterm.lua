local wezterm = require 'wezterm'

local act = wezterm.action

local config = wezterm.config_builder()
config.color_scheme = "Material (base16)"
config.default_prog = { 'pwsh', '-nologo' }
config.font = wezterm.font 'Roboto Mono'
config.font_size = 13.0
config.hide_tab_bar_if_only_one_tab = true
config.key_tables = {
    copy_mode = {
		{ key = '/', mods = 'NONE', action = act.Search { CaseSensitiveString = ''} },
        { key = '$', mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = '0', mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
        { key = 'G', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackBottom' },
        { key = 'J', mods = 'NONE', action = act.CopyMode 'PageDown' },
        { key = 'K', mods = 'NONE', action = act.CopyMode 'PageUp' },
        { key = 'N', mods = 'NONE', action = act.CopyMode 'PriorMatch' },
        { key = 'V', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Line' } },
        { key = 'b', mods = 'NONE', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'e', mods = 'NONE', action = act.CopyMode 'MoveForwardWordEnd' },
        { key = 'g', mods = 'NONE', action = act.CopyMode 'MoveToScrollbackTop' },
        { key = 'h', mods = 'NONE', action = act.CopyMode 'MoveLeft' },
        { key = 'j', mods = 'NONE', action = act.CopyMode 'MoveDown' },
        { key = 'k', mods = 'NONE', action = act.CopyMode 'MoveUp' },
        { key = 'l', mods = 'NONE', action = act.CopyMode 'MoveRight' },
        { key = 'n', mods = 'NONE', action = act.CopyMode 'NextMatch' },
        { key = 'q', mods = 'NONE', action = act.CopyMode 'Close' },
        { key = 'v', mods = 'NONE', action = act.CopyMode { SetSelectionMode = 'Cell' } },
        { key = 'v', mods = 'CTRL', action = act.CopyMode { SetSelectionMode = 'Block' } },
        { key = 'w', mods = 'NONE', action = act.CopyMode 'MoveForwardWord' },
        {
            key = 'y',
            mods = 'NONE',
            action = act.Multiple {
                { CopyTo = 'ClipboardAndPrimarySelection' },
                { CopyMode = 'Close' },
            },
        },
    },
	search_mode = {
		{ key = 'Enter', mods = 'NONE', action = act.ActivateCopyMode },
        { key = 'Escape', mods = 'NONE', action = act.CopyMode 'Close' },
	},
}
config.keys = {
    { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = '\\', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },
    { key = 'H', mods = 'LEADER', action = act.AdjustPaneSize { 'Left', 5 } },
    { key = 'J', mods = 'LEADER', action = act.AdjustPaneSize { 'Down', 5 } },
    { key = 'K', mods = 'LEADER', action = act.AdjustPaneSize { 'Up', 5 } },
    { key = 'L', mods = 'LEADER', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = 'Q', mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
}
config.leader = { key = 'Space', mods = 'CTRL' }
config.window_decorations = 'RESIZE'

return config
