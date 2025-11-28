return {
  "stevearc/conform.nvim",
  opts = {
    default_format_opts = {
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      tsx = { "prettier" },
      vue = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      less = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
      astro = { lsp_format = "prefer" },
      lua = { "stylua" },
      python = { "ruff_format" },
    },
    formatters = {
      prettier = {
        prepend_args = { "--single-quote", "--print-width", "100" },
      },
      stylua = {
        prepend_args = { "--column-width", "100" },
      },
    },
  },
}
