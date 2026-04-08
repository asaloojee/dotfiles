return {
  "echasnovski/mini.pairs",
  event = "InsertEnter",
  opts = {},
  config = function(_, opts)
    require("mini.pairs").setup(opts)

    vim.keymap.set("i", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before = line:sub(col, col)
      local after = line:sub(col + 1, col + 1)
      local pairs = { ["{"] = "}", ["("] = ")", ["["] = "]" }
      if pairs[before] == after then
        return "<CR><C-o>O"
      end
      if before == ">" and after == "<" then
        return "<CR><C-o>O"
      end
      return "<CR>"
    end, { expr = true })
  end,
}
