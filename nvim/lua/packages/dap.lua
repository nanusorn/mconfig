local dap = require('dap')

-- Define breakpoint signs and colors
vim.fn.sign_define('DapBreakpoint', { text='B', texthl='DapBreakpoint', linehl='', numhl='DapBreakpoint' })
vim.fn.sign_define('DapBreakpointCondition', { text='C', texthl='DapBreakpointCondition', linehl='', numhl='DapBreakpointCondition' })
vim.fn.sign_define('DapLogPoint', { text='L', texthl='DapLogPoint', linehl='', numhl='DapLogPoint' })
vim.fn.sign_define('DapStopped', { text='→', texthl='DapStopped', linehl='DapStoppedLine', numhl='DapStopped' })
vim.fn.sign_define('DapBreakpointRejected', { text='R', texthl='DapBreakpointRejected', linehl='', numhl='DapBreakpointRejected' })

-- Set up keymaps
vim.keymap.set('n', '<F5>', function() dap.continue() end)
vim.keymap.set('n', '<F10>', function() dap.step_over() end)
vim.keymap.set('n', '<F11>', function() dap.step_into() end)
vim.keymap.set('n', '<F12>', function() dap.step_out() end)
vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end)
vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end)

-- Example configuration for a specific language (e.g., Python)
-- Ensure you have the debugger installed (e.g., debugpy)
dap.adapters.python = {
  type = 'executable';
  command = 'python';
  args = { '-m', 'debugpy.adapter' };
}

dap.configurations.python = {
  {
    type = 'python';
    request = 'launch';
    name = "Launch file";
    program = "${file}";
    pythonPath = function()
      return 'python'
    end;
  },
}

-- CodeLLDB adapter configuration for C/C++ and Rust
dap.adapters.codelldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
    args = {"--port", "${port}"},
  }
}

-- C/C++ configurations
dap.configurations.c = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

dap.configurations.cpp = dap.configurations.c

-- Rust configurations
dap.configurations.rust = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

-- Configuration for DAP UI
local dapui = require("dapui")
dapui.setup({
  windows = { indent = 1 },
  controls = {
    enabled = true,
  },
  floating = {
    border = "rounded",
  },
})

-- Customize statusline colors for DAP UI windows
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dapui_*",
  callback = function()
    -- Set different statusline and winbar colors based on buffer name
    local bufname = vim.api.nvim_buf_get_name(0)

    if string.match(bufname, "dapui_scopes") then
      vim.cmd("setlocal winhl=StatusLine:DapUIScopes,StatusLineNC:DapUIScopesNC,WinBar:DapUIScopes,WinBarNC:DapUIScopesNC")
    elseif string.match(bufname, "dapui_breakpoints") then
      vim.cmd("setlocal winhl=StatusLine:DapUIBreakpoints,StatusLineNC:DapUIBreakpointsNC,WinBar:DapUIBreakpoints,WinBarNC:DapUIBreakpointsNC")
    elseif string.match(bufname, "dapui_stacks") then
      vim.cmd("setlocal winhl=StatusLine:DapUIStacks,StatusLineNC:DapUIStacksNC,WinBar:DapUIStacks,WinBarNC:DapUIStacksNC")
    elseif string.match(bufname, "dapui_watches") then
      vim.cmd("setlocal winhl=StatusLine:DapUIWatches,StatusLineNC:DapUIWatchesNC,WinBar:DapUIWatches,WinBarNC:DapUIWatchesNC")
    elseif string.match(bufname, "dapui_console") then
      vim.cmd("setlocal winhl=StatusLine:DapUIConsole,StatusLineNC:DapUIConsoleNC,WinBar:DapUIConsole,WinBarNC:DapUIConsoleNC")
    end
  end,
})

-- Automatically open/close UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- MASON
require("mason").setup()
require("mason-nvim-dap").setup()
