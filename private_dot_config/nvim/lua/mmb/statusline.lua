---------------------------------------------------------------
-- Sections
-- => Module definition
-- => Highlight groups
-- => Modes
-- => Settings
---------------------------------------------------------------
---------------------------------------------------------------
-- => Module definition
---------------------------------------------------------------
MmbStatusline = {}

MmbStatusline.content = function()
    local mode, mode_hl = MmbStatusline.section_mode()
    local filename = MmbStatusline.section_filename()
    local fileinfo = MmbStatusline.section_fileinfo()
    local location = MmbStatusline.section_location()

    return MmbStatusline.combine_groups({
        { hl = mode_hl, strings = { mode } },
        "%<", -- Mark general truncate point
        { hl = "*",     strings = { filename } },
        "%=", -- Flush right
        { hl = "MmbStatuslineFileinfo", strings = { fileinfo, location } },
    })
end

--- Combines groups of sections
---
--- Each group can be either a string or a table with fields `hl` (group's
--- highlight group) and `strings` (strings representing sections).
---
---@param groups table Array of groups
---
---@return string statusline String suitable for 'statusline'
MmbStatusline.combine_groups = function(groups)
    local parts = vim.tbl_map(function(s)
        if type(s) == "string" then
            return s
        end
        if type(s) ~= "table" then
            return ""
        end

        local string_arr = vim.tbl_filter(function(x)
            return type(x) == "string" and x ~= ""
        end, s.strings or {})

        local string = table.concat(string_arr, " ")

        if s.hl == nil then
            return string.format(" %s ", string)
        end

        if string:len() == 0 then
            return string.format("%%#%s#", s.hl)
        end

        return string.format("%%#%s# %s ", s.hl, string)
    end, groups)

    local statusline = table.concat(parts, "")
    return statusline
end

--- Section for Vim |mode()|
---
---@return string mode_info.short Short mode text
---@return string mode_info.hl Mode highlight group
MmbStatusline.section_mode = function()
    local mode_info = Mode[vim.api.nvim_get_mode().mode]
    return mode_info.short, mode_info.hl
end

--- Section for file name
---
--- Shows full file name with readonly indicator and modified indicator.
---
---@return string
MmbStatusline.section_filename = function()
    return "%F %r %m"
end

--- Section for file information
---
--- Shows filetype, encoding, and format.
---
--- @return string
MmbStatusline.section_fileinfo = function()
    local filetype = vim.bo.filetype
    if filetype == "" then
        return ""
    end

    local encoding = string.format(
        "%s%s",
        vim.bo.fileencoding or vim.bo.encoding,
        vim.bo.bomb and "-BOM" or ""
    )
    local format = vim.bo.fileformat

    return string.format("%s %s[%s]", filetype, encoding, format)
end

--- Section for location inside buffer
---
--- Shows `'<percentage through file>|<cursor column>'`
---
--- @return string
MmbStatusline.section_location = function()
    return "%p%%|%v"
end

---------------------------------------------------------------
-- => Highlight groups
---------------------------------------------------------------
vim.api.nvim_set_hl(0, "MmbStatuslineModeNormal", {
    bg = "NvimDarkGray4", fg = "NvimLightGray1"
})
vim.api.nvim_set_hl(0, "MmbStatuslineModeInsert", {
    bg = "NvimLightGreen", fg = "NvimDarkGray1"
})
vim.api.nvim_set_hl(0, "MmbStatuslineModeVisual", {
    bg = "NvimLightRed", fg = "NvimDarkGray1"
})
vim.api.nvim_set_hl(0, "MmbStatuslineModeReplace", {
    bg = "NvimLightYellow", fg = "NvimDarkGray1"
})
vim.api.nvim_set_hl(0, "MmbStatuslineModeCommand", {
    bg = "NvimLightBlue", fg = "NvimDarkGray1"
})
vim.api.nvim_set_hl(0, "MmbStatuslineModeOther", {
    bg = "NvimLightMagenta", fg = "NvimDarkGray1"
})

vim.api.nvim_set_hl(0, "MmbStatuslineFileinfo", { link = "MmbStatuslineModeNormal" })

---------------------------------------------------------------
-- => Mode
---------------------------------------------------------------
Mode = setmetatable({
    ["n"]     = { long = "Normal", short = "N", hl = "MmbStatuslineModeNormal" },
    ["no"]    = { long = "Operator-pending", short = "O-P", hl = "MmbStatuslineModeOther" },
    ["nov"]   = { long = "Operator-pending", short = "O-P", hl = "MmbStatuslineModeOther" },
    ["noV"]   = { long = "Operator-pending", short = "O-P", hl = "MmbStatuslineModeOther" },
    ["no\22"] = { long = "Operator-pending", short = "O-P", hl = "MmbStatuslineModeOther" },
    ["niI"]   = { long = "Normal", short = "N", hl = "MmbStatuslineModeNormal" },
    ["niR"]   = { long = "Normal", short = "N", hl = "MmbStatuslineModeNormal" },
    ["niV"]   = { long = "Normal", short = "N", hl = "MmbStatuslineModeNormal" },
    ["nt"]    = { long = "Normal", short = "N", hl = "MmbStatuslineModeNormal" },
    ["ntT"]   = { long = "Normal", short = "N", hl = "MmbStatuslineModeNormal" },
    ["v"]     = { long = "Visual", short = "V", hl = "MmbStatuslineModeVisual" },
    ["vs"]    = { long = "Visual", short = "V", hl = "MmbStatuslineModeVisual" },
    ["V"]     = { long = "V-Line", short = "V-L", hl = "MmbStatuslineModeVisual" },
    ["Vs"]    = { long = "V-Line", short = "V-L", hl = "MmbStatuslineModeVisual" },
    ["\22"]   = { long = "V-Block", short = "V-B", hl = "MmbStatuslineModeVisual" },
    ["\22s"]  = { long = "V-Block", short = "V-B", hl = "MmbStatuslineModeVisual" },
    ["s"]     = { long = "Select", short = "S", hl = "MmbStatuslineModeVisual" },
    ["S"]     = { long = "S-Line", short = "S-L", hl = "MmbStatuslineModeVisual" },
    ["\19"]   = { long = "S-Block", short = "S-B", hl = "MmbStatuslineModeVisual" },
    ["i"]     = { long = "Insert", short = "I", hl = "MmbStatuslineModeInsert" },
    ["ic"]    = { long = "Insert", short = "I", hl = "MmbStatuslineModeInsert" },
    ["ix"]    = { long = "Insert", short = "I", hl = "MmbStatuslineModeInsert" },
    ["R"]     = { long = "Replace", short = "R", hl = "MmbStatuslineModeReplace" },
    ["Rc"]    = { long = "Replace", short = "R", hl = "MmbStatuslineModeReplace" },
    ["Rx"]    = { long = "Replace", short = "R", hl = "MmbStatuslineModeReplace" },
    ["Rv"]    = { long = "V-Replace", short = "V-R", hl = "MmbStatuslineModeVisual" },
    ["Rvc"]   = { long = "V-Replace", short = "V-R", hl = "MmbStatuslineModeVisual" },
    ["Rvx"]   = { long = "V-Replace", short = "V-R", hl = "MmbStatuslineModeVisual" },
    ["c"]     = { long = "Command", short = "C", hl = "MmbStatuslineModeCommand" },
    ["cr"]    = { long = "Command", short = "C", hl = "MmbStatuslineModeCommand" },
    ["cv"]    = { long = "EX", short = "EX", hl = "MmbStatuslineModeOther" },
    ["ce"]    = { long = "EX", short = "EX", hl = "MmbStatuslineModeOther" },
    ["r"]     = { long = "Prompt", short = "P", hl = "MmbStatuslineModeOther" },
    ["rm"]    = { long = "Prompt", short = "P", hl = "MmbStatuslineModeOther" },
    ["r?"]    = { long = "Prompt", short = "P", hl = "MmbStatuslineModeOther" },
    ["!"]     = { long = "Shell", short = "Sh", hl = "MmbStatuslineModeOther" },
    ["t"]     = { long = "Terminal", short = "T", hl = "MmbStatuslineModeOther" },
}, {
    __index = function()
        return { long = "Unknown", short = "U", hl = "%#MmbStatuslineModeOther" }
    end,
})

---------------------------------------------------------------
-- => Settings
---------------------------------------------------------------
-- Always show the status line
vim.opt.laststatus = 2

-- Hide mode display in the last line
vim.opt.showmode = false

-- Export module
_G.MmbStatusline = MmbStatusline
vim.opt.statusline = "%{%v:lua.MmbStatusline.content()%}"

