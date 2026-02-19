return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    opts = {
      keymap = { 
        preset = 'default',
        ['<Tab>'] = { 'select_and_accept', 'snippet_forward', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' }
      },
      appearance = {
        nerd_font_variant = 'mono'
      },
      completion = {
        documentation = { auto_show = false },
        trigger = {
          show_on_trigger_character = false,
        },
      },
      cmdline = { enabled = false },
      sources = {
        default = { 'lsp', 'path', 'buffer' }
      },
      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
  }
}