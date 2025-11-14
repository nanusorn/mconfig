return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim', build = 'make'
      },
    },

    config = function()
      local telescope = require('telescope')
      local builtin = require('telescope.builtin')
      local themes = require('telescope.themes')
      local actions = require('telescope.actions')

      telescope.setup({
        pickers = {
          find_files = {
            theme = 'ivy'
          },
          live_grep = {
            theme = 'ivy'
          },
          grep_string = {
            theme = 'ivy'
          },
          buffers = {
            theme = 'ivy'
          },
        },
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
            n = {
              ['j'] = actions.move_selection_next,
              ['k'] = actions.move_selection_previous,
            }
          }
        }
      })

      -- find files in current directoty
      vim.keymap.set('n', '<leader>fd', function()
        builtin.find_files({})
      end)

      -- find files in neovim config folder
      vim.keymap.set('n', '<leader>en', function()
        builtin.find_files({
          cwd = vim.fn.stdpath('config')
        })
      end)

      -- live grep
      vim.keymap.set('n', '<leader>ps', function()
        builtin.live_grep({})
      end)

      -- grep current string
      vim.keymap.set('n', '<leader>pw', function()
        builtin.grep_string({})
      end)

      -- show opened buffers
      vim.keymap.set('n', '<leader>bf', function()
        builtin.buffers({})
      end)

      -- delete current buffer
      vim.keymap.set("n", "<leader>db", "<cmd>bd!<CR>",
        { noremap = true, silent = true, desc = "Force delete current buffer" })
    end,
  }
}
