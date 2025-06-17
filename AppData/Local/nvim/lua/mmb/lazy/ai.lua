local spinner = {
	filetype = "codecompanion",
	index = 1,
	namespace_id = nil,
	processing = false,
	symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
	timer = nil,
}

function spinner:get_buf(filetype)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == filetype then
			return buf
		end
	end
	return nil
end

function spinner:setup()
	self.namespace_id = vim.api.nvim_create_namespace("CodeCompanionSpinner")

	vim.api.nvim_create_augroup("CodeCompanionHooks", { clear = true })
	local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequest*",
		group = group,
		callback = function(request)
			if request.match == "CodeCompanionRequestStarted" then
				self:start()
			elseif request.match == "CodeCompanionRequestFinished" then
				self:stop()
			end
		end,
	})
end

function spinner:start()
	self.processing = true
	self.index = 0

	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end

	self.timer = vim.uv.new_timer()
	self.timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			self:update()
		end)
	)
end

function spinner:stop()
	self.processing = false

	if self.timer then
		self.timer:stop()
		self.timer:close()
		self.timer = nil
	end

	local buf = self:get_buf(self.filetype)
	if buf == nil then
		return
	end

	vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)
end

function spinner:update()
	if not self.processing then
		self:stop()
		return
	end

	local buf = self:get_buf(self.filetype)
	if buf == nil then
		return
	end

	local last_line = vim.api.nvim_buf_line_count(buf) - 1
	self.index = (self.index % #self.symbols) + 1
	vim.api.nvim_buf_clear_namespace(buf, self.namespace_id, 0, -1)
	vim.api.nvim_buf_set_extmark(buf, self.namespace_id, last_line, 0, {
		virt_lines = { { { self.symbols[self.index] .. " Processing...", "Comment" } } },
		virt_lines_above = true,
	})
end

return {
	{
		"mammothb/copilot-auth.nvim",
		cmd = "CopilotAuth",
		event = "InsertEnter",
		config = true,
		dev = true,
	},
	{
		"zbirenbaum/copilot.lua",
		commit = "c1bb86abbed1a52a11ab3944ef00c8410520543d",
		cmd = "Copilot",
		event = "InsertEnter",
		config = true,
		opts = {
			copilot_model = "gpt-4.1",
			panel = { enabled = false },
			suggestion = { enabled = false },
			filetypes = { ["*"] = false },
		},
	},
	{
		"olimorris/codecompanion.nvim",
		tag = "v16.3.0",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "echasnovski/mini.pick", tag = "v0.16.0" },
		},
		keys = {
			{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<CR>", desc = "AI chat" },
			{ "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "AI actions" },
			{ "<leader>ae", "<cmd>CodeCompanion /explain<CR>", desc = "AI explain", mode = "v" },
		},
		config = function(_, opts)
			spinner:setup()
			require("codecompanion").setup(opts)
		end,
		opts = {
			adapters = {
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "gpt-4.1",
							},
						},
					})
				end,
			},
			display = {
				action_palette = {
					provider = "mini_pick",
					opts = {
						show_default_actions = true,
						show_default_prompt_library = false,
					},
				},
				chat = {
					window = {
						position = "right",
					},
				},
				diff = {
					enabled = true,
					layout = "vertial",
				},
			},
			strategies = {
				chat = {
					adapter = "copilot",
					keymaps = {
						send = {
							callback = function(chat)
								vim.cmd("stopinsert")
								chat:submit()
								chat:add_buf_message({ role = "llm", content = "" })
							end,
							index = 1,
						},
					},
				},
				inline = {
					adapter = "copilot",
				},
				cmd = {
					adapter = "copilot",
				},
			},
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		tag = "v8.5.0",
		ft = { "markdown", "codecompanion" },
	},
}
