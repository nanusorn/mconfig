vim.lsp.enable({
	"lua_ls",
	"svelte",
	"pyright",
	"clangd",
	"rust_analyzer",
	"gopls",
	"dockerls",
	"bashls",
})

-- Tinymist needs special configuration using new API
vim.lsp.config.tinymist = {
	cmd = { vim.fn.stdpath("data") .. "/mason/bin/tinymist" },
	filetypes = { "typst" },
	single_file_support = true,
	root_markers = { ".git" },
	settings = {
		exportPdf = "onType",
		outputPath = "$root/target/$dir/$name",
	},
}

vim.lsp.enable("tinymist")
