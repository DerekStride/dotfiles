local cmd = vim.cmd
local g = vim.g

-- opt.completeopt = { "menuone" , "noinsert", "noselect" }
-- vim.opt.completeopt = { "menuone" , "noinsert", "noselect" }

-- Don't show the dumb matching stuff.
cmd([[set shortmess+=c]])

g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
g.completion_matching_smart_case = 1

local has_cmp, cmp = pcall(require, 'cmp')
local types = require("cmp.types")
local lspkind = require('lspkind')

lspkind.init()

if has_cmp then
  cmp.setup {
    mapping = {
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<C-n>'] = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
      ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
      ["<tab>"] = cmp.config.disable,
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
      { name = 'luasnip' },
      { name = "path" },
      { name = "buffer", keyword_length = 5 },
    },
    completion = {
      keyword_length = 3,
    },
    snippet = {
      expand = function(args)
        require'luasnip'.lsp_expand(args.body)
      end
    },
    formatting = {
      format = lspkind.cmp_format {
        with_text = true,
        menu = {
          buffer = "[buf]",
          nvim_lsp = "[LSP]",
          nvim_lua = "[api]",
          path = "[path]",
          luasnip = "[snip]",
        },
      },
    },
    sorting = {
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.kind,
        -- cmp.config.compare.kind places snippets above other types.
        -- I prefer to have snippets listed last.
        -- function(entry1, entry2)
        --   return cmp.config.compare.kind(entry2, entry1)
        -- end,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
  }
end
