-- command ine area, styling...
-- vim.api.nvim_set_hl(0, "Normal", { bg="#7aa2f8" })
-- vim.cmd.highlight('MsgArea guibg=#7AA2F8 guifg=#FFFFFF')
vim.api.nvim_set_hl(0, "MsgArea", {
  bg = "#7AA2F8",
  -- fg = "#D4266D",
  fg = "#000000",
  bold = true
})

-- Set line numbers to green
vim.api.nvim_set_hl(0, "LineNr", { fg = "#00FF00" })
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#909090" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#909090" })
