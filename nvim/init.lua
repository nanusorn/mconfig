vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showtabline = 2
vim.o.signcolumn = "yes"
vim.o.swapfile = false
vim.o.winborder = "rounded"
vim.g.mapleader = " "

vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')

-- Buffer navigation keymaps
vim.keymap.set('n', '<Tab>', ':bnext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>x', ':bdelete<CR>', { noremap = true, silent = true, desc = 'Close buffer' })
vim.keymap.set('n', '<leader>X', ':bdelete!<CR>', { noremap = true, silent = true, desc = 'Force close buffer' })

vim.pack.add({
	{ src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-mini/mini.pick" },
	{ src = "https://github.com/nvim-mini/mini.tabline" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/kaarmu/typst.vim" },
})

-- auto complete
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)

		if not client then return end

		-- Enable completion
		if client.server_capabilities.completionProvider then
			-- Set omnifunc for manual completion
			vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

			-- Try to enable built-in completion if available
			if vim.lsp.completion and vim.lsp.completion.enable then
				vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
				print("LSP completion enabled for " .. client.name)
			else
				print("vim.lsp.completion not available")
			end

			-- Fallback: Auto-trigger completion on text change
			vim.api.nvim_create_autocmd('TextChangedI', {
				buffer = bufnr,
				callback = function()
					local line = vim.api.nvim_get_current_line()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					local before_cursor = line:sub(1, col)

					-- Trigger on dot, colon, or after typing 2+ characters
					if before_cursor:match('[%.:]%s*$') or before_cursor:match('%w%w$') then
						if vim.fn.pumvisible() == 0 then
							vim.schedule(function()
								vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true), 'n', false)
							end)
						end
					end
				end,
			})
		end

		-- Add keybinding to manually trigger completion
		vim.keymap.set('i', '<C-k>', '<C-x><C-o>', { buffer = bufnr, noremap = true, desc = 'Trigger LSP completion' })

		-- Also map Tab to cycle through completions
		vim.keymap.set('i', '<Tab>', function()
			if vim.fn.pumvisible() == 1 then
				return '<C-n>'
			else
				return '<Tab>'
			end
		end, { buffer = bufnr, expr = true, desc = 'Next completion' })

		vim.keymap.set('i', '<S-Tab>', function()
			if vim.fn.pumvisible() == 1 then
				return '<C-p>'
			else
				return '<S-Tab>'
			end
		end, { buffer = bufnr, expr = true, desc = 'Previous completion' })
	end,
})

require "vague".setup({
	transparent = true
})
require "mini.pick".setup({})
require "mini.tabline".setup({})
require "oil".setup({
	lsp_file_methods = {
		enabled = true,
		timeout_ms = 1000,
		autosave_changes = true,
	},
	columns = {
		"permissions",
		"icon",
	},
	float = {
		max_width = 0.7,
		max_height = 0.6,
		border = "rounded",
	},
})

-- Typst configuration
vim.api.nvim_set_hl(0, "TypstError", { fg = "#8B0000", bold = true })

local function show_error(msg)
	vim.api.nvim_echo({{msg, "TypstError"}}, true, {})
end

-- Auto-compile Typst files on save
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.typ",
	callback = function()
		local file = vim.fn.expand("%:p")
		local cmd = string.format("typst compile '%s'", file)
		local stderr_data = {}
		local stdout_data = {}

		vim.fn.jobstart(cmd, {
			on_stderr = function(_, data)
				if data then
					vim.list_extend(stderr_data, data)
				end
			end,
			on_stdout = function(_, data)
				if data then
					vim.list_extend(stdout_data, data)
				end
			end,
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					vim.notify("✓ Typst compiled successfully", vim.log.levels.INFO)
				else
					local error_msg = table.concat(stderr_data, "\n")
					if error_msg == "" then
						error_msg = table.concat(stdout_data, "\n")
					end
					show_error("✗ Typst compilation failed:\n" .. error_msg)
				end
			end,
		})
	end,
})

-- Typst keymaps
vim.api.nvim_create_autocmd("FileType", {
	pattern = "typst",
	callback = function()
		local opts = { buffer = true, silent = true }

		-- Compile current file (shows full output)
		vim.keymap.set("n", "<leader>tc", function()
			vim.cmd("!typst compile %")
		end, vim.tbl_extend("force", opts, { desc = "Typst: Compile (show output)" }))

		-- Check for errors (verbose)
		vim.keymap.set("n", "<leader>te", function()
			local file = vim.fn.expand("%:p")
			vim.cmd("split")
			vim.cmd("terminal typst compile '" .. file .. "'")
		end, vim.tbl_extend("force", opts, { desc = "Typst: Check errors" }))

		-- Compile and open PDF
		vim.keymap.set("n", "<leader>tp", function()
			local file = vim.fn.expand("%:p")
			local pdf = vim.fn.expand("%:p:r") .. ".pdf"
			vim.fn.system(string.format("typst compile '%s'", file))
			vim.fn.system(string.format("open '%s'", pdf))
		end, vim.tbl_extend("force", opts, { desc = "Typst: Compile & Preview" }))

		-- Start watch mode in background
		vim.keymap.set("n", "<leader>tw", function()
			local file = vim.fn.expand("%:p")
			local cmd = string.format("typst watch '%s'", file)
			vim.fn.jobstart(cmd, {
				on_stdout = function(_, data)
					if data and #data > 0 then
						vim.notify("Typst watch: " .. table.concat(data, "\n"), vim.log.levels.INFO)
					end
				end,
			})
			vim.notify("Started Typst watch mode", vim.log.levels.INFO)
		end, vim.tbl_extend("force", opts, { desc = "Typst: Watch mode" }))
	end,
})

vim.keymap.set('n', '<leader>f', ":Pick files<CR>")
vim.keymap.set('n', '<leader>h', ":Pick help<CR>")
vim.keymap.set('n', '<leader>b', ":Pick buffers<CR>")
vim.keymap.set('n', '<leader>e', ":Oil<CR>")

-- LSP Configuration
local lspconfig = require('lspconfig')

-- Helper function to check if executable exists
local function server_exists(name)
	return vim.fn.executable(name) == 1
end

-- Setup LSP servers (only if installed)
local servers = {
	{ name = 'lua_ls', cmd = 'lua-language-server', config = {
		settings = {
			Lua = {
				runtime = { version = 'LuaJIT' },
				diagnostics = { globals = { 'vim' } },
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = { enable = false },
			}
		}
	}},
	{ name = 'rust_analyzer', cmd = 'rust-analyzer', config = {} },
	{ name = 'eslint', cmd = 'vscode-eslint-language-server', config = {} },
	{ name = 'svelte', cmd = 'svelteserver', config = {} },
	{ name = 'tailwindcss', cmd = 'tailwindcss-language-server', config = {} },
	{ name = 'ts_ls', cmd = 'typescript-language-server', config = {} },
	{ name = 'yamlls', cmd = 'yaml-language-server', config = {} },
	{ name = 'html', cmd = 'vscode-html-language-server', config = {} },
	{ name = 'cssls', cmd = 'vscode-css-language-server', config = {} },
	{ name = 'bashls', cmd = 'bash-language-server', config = {} },
	{ name = 'gopls', cmd = 'gopls', config = {} },
	{ name = 'jsonls', cmd = 'vscode-json-language-server', config = {} },
	{ name = 'tinymist', cmd = 'tinymist', config = {} },
}

for _, server in ipairs(servers) do
	if server_exists(server.cmd) then
		lspconfig[server.name].setup(server.config)
	end
end

-- LSP Keymaps
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, {noremap = true, silent = true})
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {noremap = true, silent = true})
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {noremap = true, silent = true})
vim.keymap.set('n', 'gr', vim.lsp.buf.references, {noremap = true, silent = true})
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {noremap = true, silent = true})

vim.cmd("colorscheme vague")
vim.cmd(":hi statusline guibg=NONE")
