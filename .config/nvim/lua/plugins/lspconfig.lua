return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- CSS: ignore unknown at-rules (Tailwind @apply, @tailwind, etc.)
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

      -- HTML
      html = {
        filetypes = { "html" },
      },

      -- ESLint
      eslint = {},

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
          local venv_path = config.root_dir .. "/.venv"
          if vim.fn.isdirectory(venv_path) == 1 then
            config.settings.python.pythonPath = venv_path .. "/bin/python"
          end
        end,
      },
    },
  },
}
