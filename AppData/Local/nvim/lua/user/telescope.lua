local ok, telescope = pcall(require, "telescope")
if not ok then
    return
end

local actions = telescope.actions
telescope.setup({
  defaults = {
      path_display = { "smart" },
  },
  pickers = {
      planets = {
          show_pluto = true,
      },
  },
  extensions = {},
})
