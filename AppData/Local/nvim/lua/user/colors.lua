local g = vim.g
local opt = vim.opt

opt.background = "dark"
g.material_theme_style = "default"
pcall(vim.cmd, "colorscheme material")

vim.cmd("highlight ColorColumn ctermbg=0 guibg=Black")
vim.cmd("highlight LineNr ctermfg=8 guifg=DarkGrey")

