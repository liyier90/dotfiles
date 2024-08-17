local ok, telescope = pcall(require, "telescope")
if not ok then
    return
end

telescope.setup({
    defaults = {
        path_display = { "smart" },
        vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--trim"
        },
    },
    extensions = {},
    pickers = {
        find_files = {
            find_command = {
                "rg",
                "--files",
                "--color=never",
                "--no-heading",
                "--line-number",
                "--column",
                "--smart-case",
                "--path-separator",
                "/",
            },
        },
        planets = {
            show_pluto = true,
        },
    },
})

local map = vim.keymap.set
-- No remap by default
local default_opts = { noremap = true }
local builtin = require("telescope.builtin")

local function wrap(func, ...)
    local opts = { ... }
    return function()
        func(unpack(opts))
    end
end

map("n", "<leader>fa", wrap(builtin.find_files, { follow = true, no_ignore = true, hidden = true }), default_opts)
map("n", "<leader>fb", builtin.buffers, default_opts)
map("n", "<leader>ff", builtin.find_files, default_opts)
map("n", "<leader>fg", builtin.live_grep, default_opts)