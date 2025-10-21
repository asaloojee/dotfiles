return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "css",
        "scss",
        "tsx",
        "typescript",
        "javascript",
        "astro",
        "html",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
      })
    end,
  },
}
