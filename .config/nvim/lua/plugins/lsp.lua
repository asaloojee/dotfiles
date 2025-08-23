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
        filetypes = { "css", "scss", "less", "html", "javascript", "javascriptreact", "typescript", "typescriptreact" },
      },
      tailwindcss = {
        filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
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
      tsserver = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            }
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            }
          }
        }
      },
    },
  },
}