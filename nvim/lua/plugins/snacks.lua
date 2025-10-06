return {
  {
    "folke/snacks.nvim",

    priority = 1000,
    lazy = false,

    opts = {
      dashboard = {
        enabled = true,
        preset = {
          header = [[
███╗   ███╗ ██████╗██████╗ ██╗   ██╗ ██████╗██╗  ██╗
████╗ ████║██╔════╝██╔══██╗██║   ██║██╔════╝██║ ██╔╝
██╔████╔██║██║     ██║  ██║██║   ██║██║     █████╔╝
██║╚██╔╝██║██║     ██║  ██║██║   ██║██║     ██╔═██╗
██║ ╚═╝ ██║╚██████╗██████╔╝╚██████╔╝╚██████╗██║  ██╗
╚═╝     ╚═╝ ╚═════╝╚═════╝  ╚═════╝  ╚═════╝╚═╝  ╚═╝
          ]],
        },
      },
      lazygit = {
        enabled = true
      },
      explorer = {
        enabled = true
      },
      picker = {
        enabled = true
      },
      rename = {
        enabled = true
      },
      bufdelete = {
        enabled = true
      },
    },

    -- -- NOTE: Keymaps
    keys = {
      { "<leader>lg", function() require("snacks").lazygit() end,            desc = "Lazygit" },
      { "<leader>gl", function() require("snacks").lazygit.log() end,        desc = "Lazygit Logs" },
      { "<leader>es", function() require("snacks").explorer() end,           desc = "Open Snacks Explorer" },
      { "<leader>rN", function() require("snacks").rename.rename_file() end, desc = "Fast Rename Current File" },
      { "<leader>dB", function() require("snacks").bufdelete() end,          desc = "Delete or Close Buffer  (Confirm)" },
      {
        "<leader>ee",
        function()
          -- Get current window
          local current_win = vim.api.nvim_get_current_win()
          local wins = vim.api.nvim_list_wins()

          -- Find leftmost window (likely the explorer)
          local leftmost_win = nil
          local leftmost_col = math.huge

          for _, win in ipairs(wins) do
            if vim.api.nvim_win_is_valid(win) then
              local pos = vim.api.nvim_win_get_position(win)
              if pos[2] < leftmost_col then
                leftmost_col = pos[2]
                leftmost_win = win
              end
            end
          end

          -- If we found a leftmost window and it's not the current one, focus it
          if leftmost_win and leftmost_win ~= current_win then
            vim.api.nvim_set_current_win(leftmost_win)
          else
            -- Otherwise open explorer
            require("snacks").explorer()
          end
        end,
        desc = "Focus Left Window/Explorer"
      },

      -- Snacks Picker
      { "<leader>pf",  function() require("snacks").picker.files() end,                                             desc = "Find Files (Snacks Picker)" },
      { "<leader>pc",  function() require("snacks").picker.files({ cwd = "~/dotfiles/nvim/.config/nvim/lua" }) end, desc = "Find Config File" },
      { "<leader>ps",  function() require("snacks").picker.grep() end,                                              desc = "Grep word" },
      { "<leader>pws", function() require("snacks").picker.grep_word() end,                                         desc = "Search Visual selection or Word", mode = { "n", "x" } },
      { "<leader>pk",  function() require("snacks").picker.keymaps({ layout = "ivy" }) end,                         desc = "Search Keymaps (Snacks Picker)" },

      -- Git Stuff
      { "<leader>gbr", function() require("snacks").picker.git_branches({ layout = "select" }) end,                 desc = "Pick and Switch Git Branches" },

      -- Other Utils
      { "<leader>th",  function() require("snacks").picker.colorschemes({ layout = "ivy" }) end,                    desc = "Pick Color Schemes" },
      { "<leader>vh",  function() require("snacks").picker.help() end,                                              desc = "Help Pages" },
    },
  },

  -- NOTE: todo comments w/ snacks
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    optional = true,
    keys = {
      { "<leader>pt", function() require("snacks").picker.todo_comments() end,                                          desc = "Todo" },
      { "<leader>pT", function() require("snacks").picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },
}
