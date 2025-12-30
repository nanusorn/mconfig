-- Load the nvim-treesitter plugin first
vim.cmd.packadd("nvim-treesitter")

-- Add nvim-treesitter runtime to runtimepath for queries
local treesitter_runtime = vim.fn.stdpath("data") .. "/site/pack/core/opt/nvim-treesitter/runtime"
vim.opt.runtimepath:prepend(treesitter_runtime)

-- Setup nvim-treesitter with new API
require("nvim-treesitter").setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Install parsers for Svelte and dependencies (async, won't block)
require("nvim-treesitter").install({
	"lua",
	"python",
	"svelte",
	"javascript",
	"typescript",
	"html",
	"css",
	"c",
	"cpp",
	"rust",
	"go",
	"dockerfile",
	"bash",
	"vim",
	"vimdoc",
	"typst",
})

-- Enable Tree-sitter highlighting for all buffers
vim.api.nvim_create_autocmd({ "LspAttach", "FileType", "BufEnter" }, {
	pattern = {
		"lua",
		"python",
		"svelte",
		"javascript",
		"typescript",
		"html",
		"css",
		"c",
		"cpp",
		"rust",
		"go",
		"dockerfile",
		"sh",
		"bash",
		"vim",
		"help",
		"typst",
	},
	callback = function(args)
		-- Set up LSP omnifunc for manual completion (on LspAttach)
		if args.event == "LspAttach" and args.data and args.data.client_id then
			-- Just ensure omnifunc is set (it should be automatic, but let's be explicit)
			vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		end

		-- Force Tree-sitter to start
		local ok = pcall(vim.treesitter.start, args.buf)
		if ok then
			-- Ensure highlighting is actually enabled
			vim.bo[args.buf].syntax = ""
		end
	end,
})

-- Set completion options
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Also enable for already open buffers
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local supported_fts = {
			"svelte",
			"javascript",
			"typescript",
			"lua",
			"python",
			"c",
			"cpp",
			"rust",
			"go",
			"dockerfile",
			"sh",
			"bash",
			"vim",
			"help",
			"typst",
		}
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			for _, ft in ipairs(supported_fts) do
				if vim.bo[buf].filetype == ft then
					pcall(vim.treesitter.start, buf)
					break
				end
			end
		end
	end,
})
