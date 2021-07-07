local has_treesitter, config = pcall(require, 'nvim-treesitter.configs')

if not has_treesitter then return end

local read_query = function(filename)
  return table.concat(vim.fn.readfile(vim.fn.expand(filename)), "\n")
end

config.setup {
  ensure_installed = { 'ruby', 'rust', 'bash', 'lua', 'html', 'query' }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,
  },
  parsers = {
    lua = {
      injections = read_query("$ZSH/nvim/tree-sitter/queries/lua/injections.scm"),
    }
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false -- Whether the query persists across vim sessions
  },
  query_linter = {
    enable = true,
    use_virtual_text = true,
    lint_events = {"BufWrite", "CursorHold"},
  }
}
