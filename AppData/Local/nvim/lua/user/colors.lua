vim.opt.background = "dark"
vim.g.material_style = "oceanic"

local ok, material = pcall(require, "material")
if ok then
    vim.cmd "colorscheme material"
end 

vim.cmd "highlight ColorColumn ctermbg=0 guibg=Black"
vim.cmd "highlight LineNr ctermfg=8 guifg=DarkGrey"
