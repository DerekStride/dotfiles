local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local g = vim.g

-- opt.completeopt = { "menuone" , "noinsert", "noselect" }

-- Don't show the dumb matching stuff.
cmd([[set shortmess+=c]])

g.completion_confirm_key = ""
g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
g.completion_matching_smart_case = 1

-- Decide on length
g.completion_trigger_keyword_length = 2

local t = function(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col('.') - 1
  if col == 0 then return true end
  if fn.getline('.'):sub(col, col):match('%s') then return true end
  return false
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if fn.pumvisible() == 1 then
    return t("<C-n>")
  -- elseif vim.fn.call("vsnip#available", {1}) == 1 then
  --   return t("<Plug>(vsnip-expand-or-jump)")
  elseif check_back_space() then
    return t("<Tab>")
  else
    return fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if fn.pumvisible() == 1 then
    return t("<C-p>")
  -- elseif fn.call("vsnip#jumpable", {-1}) == 1 then
  --   return t("<Plug>(vsnip-jump-prev)")
  else
    return t("<S-Tab>")
  end
end

api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

local has_compe, compe = pcall(require, 'compe')
if has_compe then
  compe.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    allow_prefix_unmatch = false;

    source = {
      path = true;
      buffer = true;
      calc = true;
      vsnip = false;
      nvim_lsp = true;
      nvim_lua = true;
      spell = true;
      tags = false;
      snippets_nvim = true;
    };
  }
end
