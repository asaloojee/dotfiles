return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            padding = { left = 1, right = 1 },
            color = { gui = "bold" },
          },
        },
        lualine_b = {
          {
            "branch",
            padding = { left = 1, right = 1 },
            color = { gui = "bold" },
          },
        },
        lualine_c = {
          {
            "filename",
            path = 0,
            padding = { left = 1, right = 1 },
            -- color = { gui = "bold" },
          },
        },
        lualine_x = {
          {
            "encoding",
            padding = { left = 1, right = 1 },
            -- color = { gui = "bold" },
          },
          {
            "fileformat",
            symbols = { unix = "" },
            padding = { left = 1, right = 1 },
            color = { gui = "bold" },
          },
          {
            "filetype",
            icon_only = false,
            padding = { left = 1, right = 1 },
            -- color = { gui = "bold" },
          },
        },
        lualine_y = {
          {
            "progress",
            padding = { left = 1, right = 1 },
            color = { gui = "bold" },
          },
        },
        lualine_z = {
          {
            "location",
            padding = { left = 1, right = 1 },
            color = { gui = "bold" },
          },
        },
      },
    },
  },
}
