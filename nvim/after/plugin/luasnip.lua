local ls = require("luasnip")
local types = require("luasnip.util.types")
local snippet = ls.s

ls.config.set_config {
  -- This tells LuaSnip to remember to keep around the last snippet.
  -- You can jump back into it even if you move outside of the selection
  history = true,

  -- This one is cool cause if you have dynamic snippets, it updates as you type!
  updateevents = "TextChanged,TextChangedI",

  -- Autosnippets:
  -- enable_autosnippets = true,

  -- Crazy highlights!!
  -- ext_opts = nil,
  -- ext_opts = {
  --   [types.choiceNode] = {
  --     active = {
  --       virt_text = { { " <- Current Choice", "NonTest" } },
  --     },
  --   },
  -- },
}

local shortcut = function(val)
  if type(val) == "string" then
    return { t { val }, i(0) }
  end

  if type(val) == "table" then
    for k, v in ipairs(val) do
      if type(v) == "string" then
        val[k] = t { v }
      end
    end
  end

  return val
end

local make = function(tbl)
  local result = {}
  for k, v in pairs(tbl) do
    table.insert(result, (snippet({ trig = k, desc = v.desc }, shortcut(v))))
  end

  return result
end

-- for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/derek/snips/ft/*.lua", true)) do
--   loadfile(ft_path)
-- end

local snippets = {}

snippets.rust = make(R "derek.snips.ft.rust")

ls.snippets = snippets

-- <c-k> is my expansion key
-- this will expand the current item or jump to the next item within the snippet.
vim.keymap.set({ "i", "s" }, "<c-j>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

-- <c-j> is my jump backwards key.
-- this always moves to the previous item within the snippet
vim.keymap.set({ "i", "s" }, "<c-k>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

-- <c-l> is selecting within a list of options.
-- This is useful for choice nodes
vim.keymap.set("i", "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)

-- shorcut to source my luasnips file again, which will reload my snippets
vim.keymap.set("n", "<leader><leader>s", "<cmd>source $ZSH/nvim/after/plugin/luasnip.lua<cr>")
