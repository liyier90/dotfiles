local Mode = {}

Mode.map = {
    ["n"]     = "N",
    ["no"]    = "O-P",
    ["nov"]   = "O-P",
    ["noV"]   = "O-P",
    ["no\22"] = "O-P",
    ["niI"]   = "N",
    ["niR"]   = "N",
    ["niV"]   = "N",
    ["nt"]    = "N",
    ["ntT"]   = "N",
    ["v"]     = "V",
    ["vs"]    = "V",
    ["V"]     = "V-L",
    ["Vs"]    = "V-L",
    ["\22"]   = "V-B",
    ["\22s"]  = "V-B",
    ["s"]     = "S",
    ["S"]     = "S-L",
    ["\19"]   = "S-B",
    ["i"]     = "I",
    ["ic"]    = "I",
    ["ix"]    = "I",
    ["R"]     = "R",
    ["Rc"]    = "R",
    ["Rx"]    = "R",
    ["Rv"]    = "V-R",
    ["Rvc"]   = "V-R",
    ["Rvx"]   = "V-R",
    ["c"]     = "C",
    ["cv"]    = "EX",
    ["ce"]    = "EX",
    ["r"]     = "R",
    ["rm"]    = "M",
    ["r?"]    = "P",
    ["!"]     = "SH",
    ["t"]     = "T",
}

-- @return string current mode name
function Mode.get_mode()
    local mode_code = vim.api.nvim_get_mode().mode
    if Mode.map[mode_code] == nil then
        return mode_code
    end
    return Mode.map[mode_code]
end

return Mode
