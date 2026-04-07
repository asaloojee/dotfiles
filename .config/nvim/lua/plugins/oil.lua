return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>o", function() require("oil").toggle_float() end, desc = "Oil file browser" },
  },
  opts = {},
}
