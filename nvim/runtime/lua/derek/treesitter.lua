local config = require('nvim-treesitter.configs')

config.setup {
  ensure_installed = {
    'bash',
    'comment',
    'embedded_template',
    'graphql',
    'html',
    'lua',
    'markdown',
    'markdown_inline',
    'query',
    'ruby',
    'rust',
    'sql',
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

-- local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

-- parser_config.liquid = {
--   install_info = {
--     url = "~/src/github.com/Shopify/tree-sitter-liquid", -- local path or git repo
--     files = {"src/parser.c", "src/scanner.cc"},
--     -- optional entries:
--     branch = "main", -- default branch in case of git repo if different from master
--     generate_requires_npm = false, -- if stand-alone parser without npm dependencies
--     requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
--   },
--   filetype = "liquid", -- if filetype does not match the parser name
-- }

-- require("vim.treesitter.query").set_query("liquid", "injections", "(content) @html")
-- require("vim.treesitter.query").set_query("html", "injections", "(text) @liquid")
