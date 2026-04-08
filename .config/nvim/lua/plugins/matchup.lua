return {
  "andymass/vim-matchup",
  event = "BufReadPost",
  init = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
    vim.g.matchup_surround_enabled = 1
  end,
}
