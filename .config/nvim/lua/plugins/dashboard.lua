return {
  "folke/snacks.nvim",
  lazy = false,
  opts = {
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", padding = 1 },
        { section = "keys", padding = 1 },
        { icon = " ", title = "Recent Files", padding = 1 },
        { section = "recent_files", limit = 5, padding = 1 },
      },
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = "<cmd>Telescope find_files<cr>" },
          { icon = " ", key = "g", desc = "Live Grep", action = "<cmd>Telescope live_grep<cr>" },
          { icon = " ", key = "r", desc = "Recent Files", action = "<cmd>Telescope oldfiles<cr>" },
          { icon = " ", key = "q", desc = "Quit", action = "<cmd>qa<cr>" },
        },
      },
    },
  },
}
