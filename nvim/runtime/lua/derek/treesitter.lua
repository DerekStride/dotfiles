local config = require('nvim-treesitter.configs')

config.setup {
  ensure_installed = {
    'ruby',
    'rust',
    'bash',
    'lua',
    'html',
    'sql',
    'query'
  },
  highlight = {
    enable = true,
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
