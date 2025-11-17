return {
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    config = function()
      local theme_colors = require("tokyonight.colors").setup()

      -- Convert named color table to array of hex strings
      local colors = {}
      for _, color in pairs(theme_colors) do
        if type(color) == "string" and color:match("^#%x%x%x%x%x%x$") then
          table.insert(colors, color)
        end
      end

      require("tiny-devicons-auto-colors").setup({
        colors = colors,
      })
    end,
  },
}
