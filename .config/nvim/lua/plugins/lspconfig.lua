return {
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

      local on_attach = function(_client, _bufnr)
        -- other configuration options
      end

      -- Configure diagnostics with icons and virtual text
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ", -- Add your error icon
            [vim.diagnostic.severity.WARN] = " ", -- Add your warning icon
            [vim.diagnostic.severity.INFO] = " ", -- Add your info icon
            [vim.diagnostic.severity.HINT] = " ", -- Add your hint icon
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })

      -- Hide all diagnostics in insert mode
      vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
          vim.diagnostic.hide()
        end,
      })

      -- Show all diagnostics when leaving insert mode
      vim.api.nvim_create_autocmd("InsertLeave", {
        callback = function()
          vim.diagnostic.show()
        end,
      })

      -- CSS Language Server
      lspconfig.cssls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
            hover = {
              documentation = true,
              references = true,
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true,
            },
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
            hover = {
              documentation = true,
              references = true,
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true,
            },
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = "ignore",
            },
            hover = {
              documentation = true,
              references = true,
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true,
            },
          },
        },
        filetypes = { "css", "scss", "less" },
      })

      -- CSS Modules Language Server
      lspconfig.cssmodules_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        settings = {
          camelCase = "dashes",
          linkToOriginalDefinition = true,
        },
        init_options = {
          camelCase = "dashes",
        },
      })

      -- Astro Language Server
      lspconfig.astro.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "astro" },
        init_options = {
          typescript = {
            tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
          },
        },
      })

      -- TypeScript Language Server (vtsls)
      lspconfig.vtsls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = "none" },
              parameterTypes = { enabled = false },
              variableTypes = { enabled = false },
              propertyDeclarationTypes = { enabled = false },
              functionLikeReturnTypes = { enabled = false },
              enumMemberValues = { enabled = false },
            },
          },
        },
      })

      -- HTML Language Server
      lspconfig.html.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "html", "astro" },
      })

      -- JSON Language Server
      lspconfig.jsonls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "json", "jsonc" },
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      })

      -- Lua Language Server
      lspconfig.lua_ls.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        filetypes = { "lua" },
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
              },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
    end,
  },
}
