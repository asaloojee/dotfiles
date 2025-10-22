-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Format with conform
vim.keymap.set({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ lsp_fallback = true })
end, { desc = "Format buffer" })

-- Auto-indent on Enter with autopairs
vim.keymap.set("i", "<CR>", function()
  if vim.fn.pumvisible() ~= 1 then
    -- If completion menu is not visible, use autopairs CR
    local npairs = require("nvim-autopairs")
    if npairs.check_break_line_char() then
      return npairs.autopairs_cr()
    else
      return "<CR>"
    end
  else
    -- If completion menu is visible, accept the selected item
    return "<CR>"
  end
end, { expr = true, noremap = true, desc = "Auto-indent on Enter" })
