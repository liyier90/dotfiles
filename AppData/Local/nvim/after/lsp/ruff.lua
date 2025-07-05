local ruff_group = vim.api.nvim_create_augroup("Ruff", {})

vim.api.nvim_create_autocmd("LspAttach", {
  group = ruff_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      return
    end
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end
  end,
  desc = "LSP: Disable hover capability from Ruff",
})

return {
  init_options = {
    settings = {
      lint = {
        enable = false,
      },
    },
  },
}
