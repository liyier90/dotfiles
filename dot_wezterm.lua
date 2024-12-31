local wezterm = require('wezterm')

local config = wezterm.config_builder()
config.color_scheme = 'Material (base16)'
config.default_cursor_style = 'SteadyBar'
config.default_prog = { 'pwsh', '-nologo' }
config.font = wezterm.font('Roboto Mono')
config.font_size = 13.0
config.hide_tab_bar_if_only_one_tab = true
config.key_tables = {
    copy_mode = {
		{
            key = '/',
            mods = 'NONE',
            action = wezterm.action.Search({ CaseSensitiveString = ''}),
        },
        {
            key = '$',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveToEndOfLineContent'),
        },
        {
            key = '0',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveToStartOfLine'),
        },
        {
            key = 'G',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveToScrollbackBottom'),
        },
        {
            key = 'J',
            mods = 'NONE',
            action = wezterm.action.CopyMode('PageDown'),
        },
        {
            key = 'K',
            mods = 'NONE',
            action = wezterm.action.CopyMode('PageUp'),
        },
        {
            key = 'N',
            mods = 'NONE',
            action = wezterm.action.CopyMode('PriorMatch'),
        },
        {
            key = 'V',
            mods = 'NONE',
            action = wezterm.action.CopyMode({SetSelectionMode = 'Line'}),
        },
        {
            key = 'b',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveBackwardWord'),
        },
        {
            key = 'e',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveForwardWordEnd'),
        },
        {
            key = 'g',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveToScrollbackTop'),
        },
        {
            key = 'h',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveLeft'),
        },
        {
            key = 'j',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveDown'),
        },
        {
            key = 'k',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveUp'),
        },
        {
            key = 'l',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveRight'),
        },
        {
            key = 'n',
            mods = 'NONE',
            action = wezterm.action.CopyMode('NextMatch'),
        },
        {
            key = 'q',
            mods = 'NONE',
            action = wezterm.action.CopyMode('Close'),
        },
        {
            key = 'v',
            mods = 'NONE',
            action = wezterm.action.CopyMode({SetSelectionMode = 'Cell'}),
        },
        {
            key = 'v',
            mods = 'CTRL',
            action = wezterm.action.CopyMode({SetSelectionMode = 'Block'}),
        },
        {
            key = 'w',
            mods = 'NONE',
            action = wezterm.action.CopyMode('MoveForwardWord'),
        },
        {
            key = 'y',
            mods = 'NONE',
            action = wezterm.action.Multiple({
                {CopyTo = 'ClipboardAndPrimarySelection'},
                {CopyMode = 'Close'},
            }),
        },
    },
	search_mode = {
		{
            key = 'Enter',
            mods = 'NONE',
            action = wezterm.action.ActivateCopyMode,
        },
        {
            key = 'Escape',
            mods = 'NONE',
            action = wezterm.action.CopyMode('Close'),
        },
	},
}
config.keys = {
    {
        key = '-',
        mods = 'LEADER',
        action = wezterm.action.SplitVertical({domain = 'CurrentPaneDomain'}),
    },
    {
        key = '\\',
        mods = 'LEADER',
        action = wezterm.action.SplitHorizontal({domain = 'CurrentPaneDomain'}),
    },
    {
        key = 'c',
        mods = 'LEADER',
        action = wezterm.action.SpawnTab("CurrentPaneDomain"),
    },
    {
        key = 'h',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection('Left'),
    },
    {
        key = 'j',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection('Down'),
    },
    {
        key = 'k',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection('Up'),
    },
    {
        key = 'l',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection('Right'),
    },
    {
        key = 'n',
        mods = 'LEADER',
        action = wezterm.action.ActivateTabRelative(1),
    },
    {
        key = 'H',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize({'Left', 5}),
    },
    {
        key = 'J',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize({'Down', 5}),
    },
    {
        key = 'K',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize({'Up', 5}),
    },
    {
        key = 'L',
        mods = 'LEADER',
        action = wezterm.action.AdjustPaneSize({'Right', 5}),
    },
    {
        key = 'Q',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentPane({confirm = false}),
    },
    {
        key = '[',
        mods = 'LEADER',
        action = wezterm.action.ActivateCopyMode,
    },
}
for i = 1, 8 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = 'LEADER',
        action = wezterm.action.MoveTab(i - 1),
    })
end
config.leader = {key = 'Space', mods = 'CTRL'}
config.show_new_tab_button_in_tab_bar = false
config.use_fancy_tab_bar = false
config.window_decorations = 'RESIZE'

return config
