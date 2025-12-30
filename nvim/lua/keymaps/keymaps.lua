vim.keymap.set('n', '<leader>w', '<Cmd>write<CR>')
vim.keymap.set('n', '<leader>q', '<Cmd>quit<CR>')

-- system clipboard
vim.keymap.set({'n', 'v', 'x'}, '<leader>y', '"+y<CR')
vim.keymap.set({'n', 'v', 'x'}, '<leader>d', '"+d<CR')

-- New tab management
vim.keymap.set({ "n", "t" }, "<Leader>t", "<Cmd>tabnew<CR>")
vim.keymap.set({ "n", "t" }, "<Leader>x", "<Cmd>tabclose<CR>")
for i = 1, 8 do
	vim.keymap.set({ "n", "t" }, "<Leader>" .. i, "<Cmd>tabnext " .. i .. "<CR>")
end

-- LSP
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)

-- Completion: Ctrl+k to trigger
vim.keymap.set('i', '<C-k>', '<C-x><C-o>', { desc = 'Trigger LSP completion' })

-- Navigate completion menu with Tab
vim.keymap.set('i', '<Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true, desc = 'Next completion item' })
vim.keymap.set('i', '<S-Tab>', function()
	return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
end, { expr = true, desc = 'Previous completion item' })

-- Pick
vim.keymap.set('n', '<leader>f', '<Cmd>Pick files<CR>')
vim.keymap.set('n', '<leader>h', '<Cmd>Pick help<CR>')

-- Oil
vim.keymap.set('n', '<leader>e', '<Cmd>Pick explore<CR>')

-- Move selected line(s) up/down in Visual mode (v, V)
vim.keymap.set('v', '<A-j>', ':m ">+1<CR>gv=gv', { desc = 'Move line down' })
vim.keymap.set('v', '<A-k>', ':m "<-2<CR>gv=gv', { desc = 'Move line up' })

-- Keymaps for Typst
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'typst',
	callback = function()
		local opts = { buffer = true, silent = true }

		-- Compile current file (shows full output)
		vim.keymap.set('n', '<leader>tc', function()
			vim.cmd('!typst compile %')
		end, vim.tbl_extend('force', opts, { desc = 'Typst: Compile (show output)' }))

		-- Check for errors (verbose)
		vim.keymap.set('n', '<leader>te', function()
			local file = vim.fn.expand('%:p')
			vim.cmd('split')
			vim.cmd('terminal typst compile "' .. file .. '"')
		end, vim.tbl_extend('force', opts, { desc = 'Typst: Check errors' }))

		-- Compile and open PDF
		vim.keymap.set('n', '<leader>tp', function()
			local file = vim.fn.expand('%:p')
			local pdf = vim.fn.expand('%:p:r') .. '.pdf'
			vim.fn.system(string.format('typst compile '%s'', file))
			vim.fn.system(string.format('open '%s'', pdf))
		end, vim.tbl_extend('force', opts, { desc = 'Typst: Compile & Preview' }))

		-- Start watch mode in background
		vim.keymap.set('n', '<leader>tw', function()
			local file = vim.fn.expand('%:p')
			local cmd = string.format('typst watch '%s'', file)
			vim.fn.jobstart(cmd, {
				on_stdout = function(_, data)
					if data and #data > 0 then
						vim.notify('Typst watch: ' .. table.concat(data, '\n'), vim.log.levels.INFO)
					end
				end,
			})
			vim.notify('Started Typst watch mode', vim.log.levels.INFO)
		end, vim.tbl_extend('force', opts, { desc = 'Typst: Watch mode' }))
	end,
})
