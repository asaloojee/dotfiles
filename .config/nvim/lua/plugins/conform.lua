return {
  "stevearc/conform.nvim",
  opts = {
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
      astro = { "prettier" },
      lua = { "stylua" },
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
