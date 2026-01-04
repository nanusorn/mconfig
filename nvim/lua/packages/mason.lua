require("mason").setup()
require("mason-lspconfig").setup()
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"stylua",
		"pyright",
		"svelte-language-server",
		"clangd",
		"rust-analyzer",
		"gopls",
		"dockerfile-language-server",
		"bash-language-server",
		"tinymist",
		"codelldb"
	},
})
