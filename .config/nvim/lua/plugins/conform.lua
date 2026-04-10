return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  keys = {
    { "<leader>cf", function() require("conform").format() end },
  },
  opts = {
    format_on_save = { timeout_ms = 3000, lsp_format = "fallback" },
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
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
        prepend_args = { "--indent-type", "Spaces", "--indent-width", "4" },
      },
    },
  },
}
