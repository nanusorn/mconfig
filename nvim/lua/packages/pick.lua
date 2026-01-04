local pick = require('mini.pick')
pick.setup()

-- Register custom explore picker
pick.registry.explore = function()
  return pick.builtin.files({ tool = 'git' }, {
    source = {
      cwd = vim.fn.getcwd(),
      show = function(buf_id, items, query)
        -- Show files in current directory
        return pick.default_show(buf_id, items, query)
      end,
    },
  })
end
