---------------------------------------------------------------
-- Sections
-- => General
-- => User interface
-- => Files, backups, and undo
-- => Text, tab, and indent
-- => Status line
---------------------------------------------------------------

---------------------------------------------------------------
-- => General
---------------------------------------------------------------
-- Enable system clipboard
vim.opt.clipboard:prepend({"unnamed", "unnamedplus"})

-- Set keystroke delay
vim.opt.timeoutlen = 500

-- Disable mouse
vim.opt.mouse = ""

-- Use block cursor in normal, visual, insert, and command modes
vim.opt.guicursor = "n-v-i-c:block-Cursor"

---------------------------------------------------------------
-- => User interface
---------------------------------------------------------------
-- Set number of lines to the cursor when moving vertically with j/k
vim.opt.scrolloff = 8

-- Remove popup menu in wildmenu
vim.opt.wildoptions:remove({"pum"})

-- Treat "@" as part of a valid file name
vim.opt.isfname:append("@-@")

-- Show vertical ruler at column 80
vim.opt.ruler = true
vim.opt.colorcolumn = "80"

-- Show relative line number
vim.opt.number = true
vim.opt.relativenumber = true

-- Always show sign column
vim.opt.signcolumn = "yes"

-- Height of the command bar
vim.opt.cmdheight = 1

-- Ignore case when searching
vim.opt.ignorecase = true

-- When searching try to be smart about cases
vim.opt.smartcase = true

-- Don't redraw while executing macros
vim.opt.lazyredraw = true

-- For regular expressions, turn magic on
vim.opt.magic = true

-- Show matching brackets when text indicator is over them
vim.opt.showmatch = true

-- How many tenths of a second to blink when matching brackets
vim.opt.matchtime = 2

-- Enable 24-bit color
vim.opt.termguicolors = true

-- Make Netrw open file in the same window
vim.g.netrw_browse_split = 0

-- Remove Netrw banner
vim.g.netrw_banner = 0

-- Set initial size of new windows in Netrw to be 25%
vim.g.netrw_winsize = 25

---------------------------------------------------------------
-- => Files, backups, and undo
---------------------------------------------------------------
-- Disable swap and backups since we have version control
vim.opt.swapfile = false
vim.opt.backup = false

-- Interval for writing swap file to disk
vim.opt.updatetime = 250

-- Enable persistant undo
vim.opt.undofile = true

-- Security
vim.opt.modeline = false
vim.opt.modelines = 0

---------------------------------------------------------------
-- => Text, tab, and indent
---------------------------------------------------------------
-- Use spaces instead of tabs
vim.opt.expandtab = true

-- Be smart when using tabs ;)
vim.opt.smarttab = true

-- 1 tab == 4 spaces
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

-- Smart auto indenting when starting a new line
vim.opt.smartindent = true

---------------------------------------------------------------
-- => Status line
---------------------------------------------------------------
-- Always show the status line
vim.opt.laststatus = 2

-- Hide mode display in the last line
vim.opt.showmode = false

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
    return string.format("%s", require("mmb.mode").get_mode()):upper()
end

function get_encoding()
    return string.format(
        "%s%s",
        vim.bo.fileencoding and vim.bo.fileencoding or vim.o.encoding,
        vim.bo.bomb and "-BOM" or ""
    )
end

function get_filetype()
    return vim.bo.filetype == "" and "none" or vim.bo.filetype
end

-- Format the status line
local statusline = {
    -- Set highlight for mode
    "%#StatusLineTerm#",
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
    "%#StatusLineTerm#",
    -- Show filetype
    " %{%v:lua.get_filetype()%} |",
    -- Show encoding
    " %{%v:lua.get_encoding()%} |",
    -- Show percentage of document length and column
    " %p%%:%c ",
}
vim.opt.statusline = table.concat(statusline, "")
