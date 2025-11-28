return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
    "mfussenegger/nvim-dap-python",
  },
  branch = "regexp",
  opts = {
    -- Auto select single venv
    auto_refresh = false,
    -- Search for venvs in these paths
    search_venv_managers = true,
    search_workspace = true,
    -- Common venv names to search for
    name = {
      "venv",
      ".venv",
      "env",
      ".env",
    },
    -- Paths to search for venvs
    path = {
      vim.fn.getcwd(),
      vim.fn.getcwd() .. "/.venv",
      vim.fn.getcwd() .. "/venv",
    },
    -- Enable telescope integration
    enable_debug_output = false,
  },
  keys = {
    {
      "<leader>vs",
      "<cmd>VenvSelect<cr>",
      desc = "Select VirtualEnv",
    },
    {
      "<leader>vc",
      "<cmd>VenvSelectCached<cr>",
      desc = "Select Cached VirtualEnv",
    },
  },
  ft = "python",
  config = function(_, opts)
    require("venv-selector").setup(opts)
  end,
}
