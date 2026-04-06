return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>" },
    { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
    { "<leader>fb", "<cmd>Telescope buffers<cr>" },
  },
  opts = {
    defaults = {
      file_ignore_patterns = { "^.git/", ".DS_Store" },
    },
    pickers = {
      find_files = { hidden = true },
    },
  },
}
