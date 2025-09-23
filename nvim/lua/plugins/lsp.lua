-- plugins/lsp.lua
return {
  -- Mason: manages external tools like LSP servers, linters, formatters
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Mason-LSPConfig: bridges Mason + lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")

      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = { 
          "rust_analyzer", 
          "gopls", 
          "ts_ls" 
        },
      })

      -- Instead of setup_handlers:
      for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
        lspconfig[server].setup({})
      end

      -- mason_lspconfig.setup_handlers({
      --   function(server_name)
      --     lspconfig[server_name].setup({})
      --   end,
      -- })

    end,
  },
}

