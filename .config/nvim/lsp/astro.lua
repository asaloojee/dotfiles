local function get_tsdk()
  local local_tsdk = vim.fs.joinpath(vim.fn.getcwd(), "node_modules", "typescript", "lib")
  if vim.uv.fs_stat(local_tsdk) then
    return local_tsdk
  end
  local tsserver = vim.fn.exepath("tsserver")
  if tsserver ~= "" then
    return vim.fs.joinpath(vim.fn.fnamemodify(vim.uv.fs_realpath(tsserver), ":h:h"), "lib", "node_modules", "typescript", "lib")
  end
  return local_tsdk
end

return {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = { "astro.config.mjs", "astro.config.ts", "package.json", ".git" },
  init_options = {
    typescript = {
      tsdk = get_tsdk(),
    },
  },
}
