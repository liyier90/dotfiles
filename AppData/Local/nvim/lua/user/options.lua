---------------------------------------------------------------
-- Sections
-- => General
-- => VIM user interface
-- => Colors and Fonts
-- => Files, backups, and undo
-- => Text, tab, and indent related
-- => Editing mappings
-- => Status line
---------------------------------------------------------------
local bo = vim.bo
local g = vim.g
local o = vim.o
local opt = vim.opt

---------------------------------------------------------------
-- => General
---------------------------------------------------------------
-- Enable system clipboard
opt.clipboard:prepend { "unnamed", "unnamedplus" }

-- Set keystroke delay
opt.timeoutlen = 500

-- Disable mouse
opt.mouse = ""

---------------------------------------------------------------
-- => VIM user interface
---------------------------------------------------------------
-- Set 7 lines to the cursor - when moving vertically using j/k
opt.scrolloff = 7

-- Avoid garbled characters in Chinese language windows OS
vim.env.LANG = "en"
opt.langmenu = "en"
vim.cmd("source $VIMRUNTIME/delmenu.vim")
vim.cmd("source $VIMRUNTIME/menu.vim")

-- Remove popup menu in wildmenu
opt.wildoptions:remove { "pum" }

-- Ignore compiled files
opt.wildignore = { "*.o", "*~", "*.pyc", "__pycache__" }
if vim.fn.has("win64") or vim.fn.has("win32") then
    opt.wildignore:append { ".git\\*", ".hg\\*", ".svn\\*" }
else
    opt.wildignore:append { "*/.git/*", "*/.hg/*", "*/.svn/*", "*/.DS_Store" }
end

-- Always show current position
opt.ruler = true
opt.colorcolumn = "80"

-- Show line number
opt.number = true

-- Height of the command bar
opt.cmdheight = 1

-- Go the prev/next line with h,l,arrows when cursor reaches start/end of line
opt.whichwrap:append "<>hl"

-- Ignore case when searching
opt.ignorecase = true

--When searching try to be smart about cases
opt.smartcase = true

-- Don't redraw while executing macros (good performance config)
opt.lazyredraw = true

-- For regular expressions turn magic on
opt.magic = true

-- Show matching brackets when text indicator is over them
opt.showmatch = true

-- How many tenths of a second to blink when matching brackets
opt.matchtime = 2

---------------------------------------------------------------
-- => Colors and Fonts
---------------------------------------------------------------
-- Encoding
opt.encoding = "utf-8"

-- Use Unix as the standard file type
opt.fileformats = { "unix", "dos", "mac" }

---------------------------------------------------------------
-- => Files, backups, and undo
---------------------------------------------------------------
-- Interval for writing swap file to disk
opt.updatetime = 250

-- Enable persistent undo
opt.undofile = true

---------------------------------------------------------------
-- => Text, tab, and indent related
---------------------------------------------------------------
-- Use spaces instead of tabs
opt.expandtab = true

-- Be smart when using tabs ;)
opt.smarttab = true

-- 1 tab == 4 spaces
opt.shiftwidth = 4
opt.tabstop = 4

opt.smartindent = true

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
-- Security
opt.modelines = 0

---------------------------------------------------------------
-- => Status line
---------------------------------------------------------------
-- Always show the status line
opt.laststatus = 2

-- Hide mode display in the last line
opt.showmode = false

-- `^V` and `^S` symbols, otherwise those symbols are not displayed
local CTRL_S = vim.api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = vim.api.nvim_replace_termcodes("<C-V>", true, true, true)

-- Map current mode
local mode_to_text = {
    ["n"] = "N",
    ["v"] = "V",
    ["V"] = "V-L",
    [CTRL_V] = "V-B",
    ["s"] = "S",
    ["S"] = "S-L",
    [CTRL_S] = "S-B",
    ["i"] = "I",
    ["R"] = "R",
    ["c"] = "C",
    ["r"] = "P",
    ["!"] = "SH",
    ["t"] = "T",
}

function get_current_mode_text()
    local curr_mode = vim.api.nvim_get_mode().mode
    return string.format("%s", mode_to_text[curr_mode]):upper()
end

function get_encoding()
    return string.format(
        "%s%s", 
        bo.fileencoding and bo.fileencoding or o.encoding,
        bo.bomb and "-BOM" or ""
    )
end

function get_filetype()
    return vim.bo.filetype == "" and "none" or vim.bo.filetype
end

-- Format the status line
local statusline = {
    -- Set highlight for mode
    "%#TabLine#",
    -- Show current mode
    " %{%v:lua.get_current_mode_text()%} ",
    -- Set default color
    "%*",
    -- Show full file path (truncate start if too long)
    " %<%F ",
    -- Show readonly
    "%r",
    -- Show modified
    "%m",
    -- Flush right
    "%=",
    -- Set highlight for encoding group
    "%#TabLine#",
    -- Show filetype
    " %{%v:lua.get_filetype()%} |",
    -- Show encoding
    " %{%v:lua.get_encoding()%} |",
    -- Show line and column
    " %l:%c ",
}
opt.statusline = table.concat(statusline, "")
