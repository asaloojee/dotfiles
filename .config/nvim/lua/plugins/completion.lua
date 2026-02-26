return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        documentation = { auto_show = false },
        trigger = {
          show_on_trigger_character = false,
        },
      },
      cmdline = { enabled = false },
      sources = {
        providers = {
          snippets = { score_offset = -10, min_keyword_length = 3 },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },
}
