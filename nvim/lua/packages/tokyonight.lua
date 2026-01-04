-- select color scheme
vim.cmd("colorscheme tokyonight")

-- Transparent background
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")
vim.cmd("hi NormalFloat guibg=NONE ctermbg=NONE")
vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE")
vim.cmd(":hi statusline guibg=NONE")

-- Bright window separators (the lines between windows)
vim.cmd("hi WinSeparator guifg=#7aa2f7 gui=bold")  -- Bright blue separators
vim.cmd("hi VertSplit guifg=#7aa2f7 gui=bold")     -- For older Neovim versions

-- Customize line number colors
vim.cmd("hi LineNr guifg=#7aa2f7")           -- Line numbers (change color here)
vim.cmd("hi CursorLineNr guifg=#ff9e64 gui=bold")  -- Current line number

-- Customize DAP breakpoint colors
vim.cmd("hi DapBreakpoint guifg=#ff0000 gui=bold")  -- Red breakpoint
vim.cmd("hi DapBreakpointCondition guifg=#ff9e64")  -- Orange conditional breakpoint
vim.cmd("hi DapLogPoint guifg=#7aa2f7")             -- Blue log point
vim.cmd("hi DapStopped guifg=#00ff00 gui=bold")     -- Green stopped indicator
vim.cmd("hi DapStoppedLine guibg=#2e3440")          -- Stopped line background
vim.cmd("hi DapBreakpointRejected guifg=#808080")   -- Gray rejected breakpoint

-- Customize DAP UI window statusline colors (active)
vim.cmd("hi DapUIScopes guifg=#1a1b26 guibg=#7aa2f7 gui=bold")         -- Blue for scopes
vim.cmd("hi DapUIBreakpoints guifg=#1a1b26 guibg=#f7768e gui=bold")    -- Red for breakpoints
vim.cmd("hi DapUIStacks guifg=#1a1b26 guibg=#9ece6a gui=bold")         -- Green for stacks
vim.cmd("hi DapUIWatches guifg=#1a1b26 guibg=#bb9af7 gui=bold")        -- Purple for watches
vim.cmd("hi DapUIConsole guifg=#1a1b26 guibg=#ff9e64 gui=bold")        -- Orange for console

-- Customize DAP UI window statusline colors (inactive) - very bright text for maximum readability
vim.cmd("hi DapUIScopesNC guifg=#ffffff guibg=#1f2335 gui=bold")       -- Pure white text, bold
vim.cmd("hi DapUIBreakpointsNC guifg=#ffffff guibg=#1f2335 gui=bold")  -- Pure white text, bold
vim.cmd("hi DapUIStacksNC guifg=#ff0000 guibg=#1f2335 gui=bold")       -- Pure white text, bold
vim.cmd("hi DapUIWatchesNC guifg=#ffffff guibg=#1f2335 gui=bold")      -- Pure white text, bold
vim.cmd("hi DapUIConsoleNC guifg=#ffffff guibg=#1f2335 gui=bold")      -- Pure white text, bold

-- DAP UI text and decoration colors (for better readability)
vim.cmd("hi DapUIWinSelect guifg=#ff007c gui=bold")          -- Window selection indicator (magenta, bold)
vim.cmd("hi DapUIVariable guifg=#c0caf5")                    -- Variable names (bright white)
vim.cmd("hi DapUIScope guifg=#7aa2f7 gui=bold")              -- Scope names (blue, bold)
vim.cmd("hi DapUIType guifg=#bb9af7")                        -- Type names (purple)
vim.cmd("hi DapUIValue guifg=#9ece6a")                       -- Variable values (green)
vim.cmd("hi DapUIModifiedValue guifg=#ff9e64 gui=bold")      -- Modified values (orange, bold)
vim.cmd("hi DapUIDecoration guifg=#7dcfff")                  -- Decorations (cyan)
vim.cmd("hi DapUIThread guifg=#9ece6a")                      -- Thread info (green)
vim.cmd("hi DapUIStoppedThread guifg=#7aa2f7 gui=bold")      -- Stopped thread (blue, bold)
vim.cmd("hi DapUIFrameName guifg=#c0caf5")                   -- Frame names (bright white)
vim.cmd("hi DapUISource guifg=#bb9af7")                      -- Source file names (purple)
vim.cmd("hi DapUILineNumber guifg=#ff9e64")                  -- Line numbers (orange)
vim.cmd("hi DapUIFloatBorder guifg=#7aa2f7")                 -- Float borders (blue)
vim.cmd("hi DapUIWatchesEmpty guifg=#565f89")                -- Empty watches (gray)
vim.cmd("hi DapUIWatchesValue guifg=#9ece6a")                -- Watch values (green)
vim.cmd("hi DapUIWatchesError guifg=#f7768e")                -- Watch errors (red)
vim.cmd("hi DapUIBreakpointsPath guifg=#7dcfff")             -- Breakpoint paths (cyan)
vim.cmd("hi DapUIBreakpointsInfo guifg=#7aa2f7")             -- Breakpoint info (blue)
vim.cmd("hi DapUIBreakpointsCurrentLine guifg=#9ece6a gui=bold")  -- Current line (green, bold)
vim.cmd("hi DapUIBreakpointsLine guifg=#565f89")             -- Other lines (gray)


