return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      cssls = {
        settings = {
          css = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            },
            hover = {
              documentation = true,
              references = true,
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true
            }
          },
          scss = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            },
            hover = {
              documentation = true,
              references = true,
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true
            }
          },
          less = {
            validate = true,
            lint = {
              unknownAtRules = "ignore"
            },
            hover = {
              documentation = true,
              references = true,
            },
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true
            }
          }
        },
        filetypes = { 'css', 'scss', 'less' },
      },
      cssmodules_ls = {
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
        settings = {
          camelCase = "dashes",
          linkToOriginalDefinition = true,
        },
        init_options = {
          camelCase = "dashes",
        },
      },
      tailwindcss = {
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "astro" },
        settings = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                "tw`([^`]*)",
                "tw=\"([^\"]*)",
                "tw={\"([^\"}]*)",
                "tw\\.\\w+`([^`]*)",
                "tw\\(.*?\\)`([^`]*)",
              },
            },
          },
        },
      },
      astro = {
        filetypes = { "astro" },
        init_options = {
          typescript = {
            tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
          },
        },
      },
      vtsls = {
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
      html = {
        filetypes = { "html", "astro" },
      },
      jsonls = {
        filetypes = { "json", "jsonc" },
        settings = {
          json = {
            validate = { enable = true },
          },
        },
      },
    },
  },
}