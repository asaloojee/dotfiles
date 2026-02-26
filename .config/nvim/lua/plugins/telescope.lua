return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      file_ignore_patterns = {
        "^.git/",
        ".DS_Store",
      },
    },
    pickers = {
      find_files = {
        hidden = true,
      },
    },
  },
}
