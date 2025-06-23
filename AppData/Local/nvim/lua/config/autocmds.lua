---------------------------------------------------------------
-- Sections
-- => Editing mappings
---------------------------------------------------------------

---Creates an augroup prefixed with 'MMB'.
---@param group_name string
---@return integer group_id
local function augroup(group_name)
  return vim.api.nvim_create_augroup(string.format("MMB%s", group_name), { clear = true })
end

---------------------------------------------------------------
-- => Editing mappings
---------------------------------------------------------------
-- Delete trailing white space on save, useful for some filetypes ;)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("RStrip"),
  pattern = "*",
  callback = function(_)
    local cursor = vim.fn.getpos(".")
    local query = vim.fn.getreg("/")
    vim.cmd([[silent! %s/\s\+$//e]])
    vim.fn.setpos(".", cursor)
    vim.fn.setreg("/", query)
  end,
})

-- Set up LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("LSPKeymap"),
  callback = function(event)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Jump to definition (LSP)", buffer = event.buf })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover information (LSP)", buffer = event.buf })
    vim.keymap.set(
      { "n", "v" },
      "<leader>gc",
      vim.lsp.buf.code_action,
      { desc = "Code action (LSP)", buffer = event.buf }
    )
    vim.keymap.set("n", "<leader>gd", vim.diagnostic.open_float, { desc = "Show diagnostic", buffer = event.buf })
    vim.keymap.set("n", "<leader>gn", vim.lsp.buf.rename, { desc = "Rename all references (LSP)", buffer = event.buf })
    vim.keymap.set(
      "n",
      "<leader>gr",
      vim.lsp.buf.references,
      { desc = "List all references (LSP)", buffer = event.buf }
    )
  end,
})

-- Detect filetype for new files
vim.api.nvim_create_autocmd("BufNewFile", {
  group = augroup("FiletypeDetect"),
  command = "filetype detect",
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("HighlightYank"),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

-- Auto create dir when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("Mkdir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end

    local file_path = vim.uv.fs_realpath(event.match) or event.match
    local parent_dir = vim.fn.fnamemodify(file_path, ":p:h")
    if vim.fn.isdirectory(parent_dir) == 1 then
      return
    end

    local response = vim.fn.input(string.format("Create '%s' automatically? [Y/n] ", parent_dir))
    while true do
      if response == "" or response:lower() == "y" then
        vim.fn.mkdir(parent_dir)
        break
      elseif response:lower() == "n" then
        break
      else
        response = vim.fn.input(string.format("Invalid input '%s'! [Y/n] ", response))
      end
    end
  end,
})
