-- Custom dark red color for error messages
vim.api.nvim_set_hl(0, "TypstError", { fg = "#8B0000", bold = true })

-- Helper function to show errors with custom color
local function show_error(msg)
	vim.api.nvim_echo({ { msg, "TypstError" } }, true, {})
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

-- Keymaps for Typst
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "typst",
-- 	callback = function()
-- 		local opts = { buffer = true, silent = true }
--
-- 		-- Compile current file (shows full output)
-- 		vim.keymap.set("n", "<leader>tc", function()
-- 			vim.cmd("!typst compile %")
-- 		end, vim.tbl_extend("force", opts, { desc = "Typst: Compile (show output)" }))
--
-- 		-- Check for errors (verbose)
-- 		vim.keymap.set("n", "<leader>te", function()
-- 			local file = vim.fn.expand("%:p")
-- 			vim.cmd("split")
-- 			vim.cmd("terminal typst compile '" .. file .. "'")
-- 		end, vim.tbl_extend("force", opts, { desc = "Typst: Check errors" }))
--
-- 		-- Compile and open PDF
-- 		vim.keymap.set("n", "<leader>tp", function()
-- 			local file = vim.fn.expand("%:p")
-- 			local pdf = vim.fn.expand("%:p:r") .. ".pdf"
-- 			vim.fn.system(string.format("typst compile '%s'", file))
-- 			vim.fn.system(string.format("open '%s'", pdf))
-- 		end, vim.tbl_extend("force", opts, { desc = "Typst: Compile & Preview" }))
--
-- 		-- Start watch mode in background
-- 		vim.keymap.set("n", "<leader>tw", function()
-- 			local file = vim.fn.expand("%:p")
-- 			local cmd = string.format("typst watch '%s'", file)
-- 			vim.fn.jobstart(cmd, {
-- 				on_stdout = function(_, data)
-- 					if data and #data > 0 then
-- 						vim.notify("Typst watch: " .. table.concat(data, "\n"), vim.log.levels.INFO)
-- 					end
-- 				end,
-- 			})
-- 			vim.notify("Started Typst watch mode", vim.log.levels.INFO)
-- 		end, vim.tbl_extend("force", opts, { desc = "Typst: Watch mode" }))
-- 	end,
-- })
