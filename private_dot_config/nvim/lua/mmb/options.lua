---------------------------------------------------------------
-- Sections
-- => General
-- => User interface
-- => Files, backups, and undo
-- => Text, tab, and indent
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
