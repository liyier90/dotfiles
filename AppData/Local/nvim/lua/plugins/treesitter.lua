-- Cannot be lazy loaded
return {
  "nvim-treesitter/nvim-treesitter",
  tag = "v0.10.0",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      auto_install = false,
      ensure_installed = { "python" },
      highlight = { enable = true },
      sync_install = true,
    })
  end,
}
