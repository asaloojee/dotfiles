return {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = { "astro.config.mjs", "astro.config.ts", "package.json", ".git" },
  init_options = {
    typescript = {
      tsdk = vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "typescript", "lib"),
    },
  },
}
