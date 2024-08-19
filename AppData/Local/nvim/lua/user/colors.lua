vim.opt.background = "dark"

local ok, material = pcall(require, "material")
if ok then
    vim.g.material_style = "oceanic"
    material.setup({
        async_loading = false,
        plugins = {
            "nvim-cmp",
            "telescope",
        }
    })
    vim.cmd("colorscheme material")
end

vim.cmd("highlight ColorColumn ctermbg=0 guibg=Black")
vim.cmd("highlight LineNr ctermfg=8 guifg=DarkGrey")
