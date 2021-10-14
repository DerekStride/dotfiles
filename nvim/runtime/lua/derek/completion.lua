local cmd = vim.cmd
local g = vim.g

-- opt.completeopt = { "menuone" , "noinsert", "noselect" }

-- Don't show the dumb matching stuff.
cmd([[set shortmess+=c]])

g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
g.completion_matching_smart_case = 1

local has_cmp, cmp = pcall(require, 'cmp')
if has_cmp then
  cmp.setup {
    mapping = {
      ['<Tab>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<Esc>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
    },
    completion = {
      keyword_length = 3,
    },
  }
end
