local read_query = function(filename)
  return table.concat(vim.fn.readfile(vim.fn.expand(filename)), "\n")
end

local query = require('vim/treesitter/query')
query.add_directive('downcase!', function(match, _, _, pred, metadata)
  local offset_node = match[pred[2]]
  P(pred)
  P(metadata)
end)
query.add_predicate('downcase?', function(match, _, _, pred, metadata)
  P(pred)
  P(metadata)
end)
P(query.list_predicates())


require('nvim-treesitter/configs').setup {
  ensure_installed = { 'ruby', 'rust', 'bash', 'lua', 'query', 'sql', 'html' }, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,
    disable = { 'query' },
  },
  parsers = {
    -- lua = {
    --   injections = read_query("~/.dotfiles/nvim/tree-sitter/queries/lua/injections.scm"),
    -- },
    -- ruby = {
    --   injections = read_query("~/.dotfiles/nvim/tree-sitter/queries/ruby/injections.scm"),
    -- }
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

