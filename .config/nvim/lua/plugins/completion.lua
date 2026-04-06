return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "*",
  opts = {
    completion = {
      documentation = { auto_show = false },
      trigger = { show_on_trigger_character = false },
    },
    sources = {
      providers = {
        snippets = { score_offset = -10, min_keyword_length = 3 },
      },
    },
  },
}
