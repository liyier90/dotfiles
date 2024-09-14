return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        auto_install = false,
        ensure_installed = {"python"},
        highlight = {enable = true},
        sync_install = true,
    },
}
