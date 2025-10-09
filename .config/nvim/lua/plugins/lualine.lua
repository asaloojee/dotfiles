return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',  -- This will use your Catppuccin colorscheme automatically
        component_separators = '|',  -- Simple vertical bar between components
        section_separators = { left = '', right = '' },  -- Powerline-style arrows for sections
      },
    },
  },
}
