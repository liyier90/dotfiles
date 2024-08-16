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

local map = vim.keymap.set

map(
    "n",
    "<leader>fa",
    "<Cmd>Telescope find_files follow=true no_ignore=true hidden=true<cr>",
    { noremap = true }
)
map("n", "<leader>fb", "<Cmd>Telescope buffers<cr>", { noremap = true })
map("n", "<leader>ff", "<Cmd>Telescope find_files<cr>", { noremap = true })
map("n", "<leader>fg", "<Cmd>Telescope live_grep<cr>", { noremap = true })
