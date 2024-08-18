local ok, treesitter = pcall(require, "nvim-treesitter")
if not ok then
    return
end

require("nvim-treesitter.configs").setup({
    auto_install = false,
    ensure_installed = { "python" },
    highlight = {
        enable = true,
    },
    sync_install = true,
})
