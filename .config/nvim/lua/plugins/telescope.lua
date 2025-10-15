return {
  "nvim-telescope/telescope.nvim",
  opts = {
    defaults = {
      -- Show hidden files in all pickers
      file_ignore_patterns = {
        "^.git/",
        ".DS_Store",
      },
    },
    pickers = {
      find_files = {
        hidden = true, -- Show hidden files
        -- If you want to also search .gitignored files, uncomment the line below:
        -- no_ignore = true,
      },
    },
  },
}
