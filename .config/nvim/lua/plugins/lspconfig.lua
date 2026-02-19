return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- CSS: ignore unknown at-rules (Tailwind's @apply, etc.)
      cssls = {
        settings = {
          css = { lint = { unknownAtRules = "ignore" } },
          scss = { lint = { unknownAtRules = "ignore" } },
          less = { lint = { unknownAtRules = "ignore" } },
        },
      },

      -- CSS Modules: go-to-definition from JS/TS into CSS module files
      cssmodules_ls = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        init_options = { camelCase = "dashes" },
      },

      -- Astro: uses local project's TypeScript SDK
      astro = {
        init_options = {
          typescript = {
            tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
          },
        },
      },

      -- TypeScript/JavaScript: skip .astro files, disable inlay hints
      vtsls = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        root_dir = function(bufnr_or_fname)
          local fname = type(bufnr_or_fname) == "number"
              and vim.api.nvim_buf_get_name(bufnr_or_fname)
            or bufnr_or_fname
          if fname:match("%.astro$") then
            return nil
          end
          return require("lspconfig.util").root_pattern(
            "package.json", "tsconfig.json", "jsconfig.json", ".git"
          )(fname)
        end,
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
      },

      -- HTML: also attach to Astro files
      html = {
        filetypes = { "html", "astro" },
      },

      -- Python: auto-detect .venv, basic type checking
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
        before_init = function(_, config)
          local venv_path = vim.fn.getcwd() .. "/.venv"
          if vim.fn.isdirectory(venv_path) == 1 then
            config.settings.python.pythonPath = venv_path .. "/bin/python"
          end
        end,
      },

      -- lua_ls and jsonls are already configured well by LazyVim
    },
  },
}
