return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Explorer sidebar" },
  },
  opts = {
    disable_netrw = true,
    hijack_netrw = true,
    view = {
      side = "left",
      width = 32,
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = false,
        },
        glyphs = {
          folder = {
            arrow_closed = ">",
            arrow_open = "v",
          },
        },
      },
    },
    git = {
      enable = true,
      ignore = false,
    },
    actions = {
      open_file = {
        quit_on_open = false,
      },
    },
    update_focused_file = {
      enable = true,
      update_root = true,
    },
  },
}
