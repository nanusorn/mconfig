vim.keymap.set("n", "<leader>w", "<Cmd>write<CR>")
vim.keymap.set("n", "<leader>q", "<Cmd>quit<CR>")

-- LSP
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)

-- Completion: Ctrl+k to trigger
vim.keymap.set("i", "<C-k>", "<C-x><C-o>", { desc = "Trigger LSP completion" })

-- Navigate completion menu with Tab
vim.keymap.set("i", "<Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true, desc = "Next completion item" })
vim.keymap.set("i", "<S-Tab>", function()
	return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, desc = "Previous completion item" })

-- Pick
vim.keymap.set("n", "<leader>f", "<Cmd>Pick files<CR>")
vim.keymap.set("n", "<leader>h", "<Cmd>Pick help<CR>")

-- Oil
vim.keymap.set("n", "<leader>e", "<Cmd>Pick explore<CR>")

-- Move selected line(s) up/down in Visual mode (v, V)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
