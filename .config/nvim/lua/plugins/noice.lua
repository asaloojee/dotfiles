return {
  "folke/noice.nvim",
  opts = {
    cmdline = {
      enabled = false, -- Disable noice cmdline, use native vim cmdline
    },
    messages = {
      enabled = false, -- Disable noice messages, use native vim messages
    },
    lsp = {
      signature = {
        auto_open = false,
      },
      -- Override markdown rendering so that **cmp** and other plugins use Treesitter
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
    },
    presets = {
      bottom_search = false, -- Disable - use native
      command_palette = false,
      long_message_to_split = true, -- Keep this - useful for long messages
      inc_rename = false,
      lsp_doc_border = false,
    },
  },
}