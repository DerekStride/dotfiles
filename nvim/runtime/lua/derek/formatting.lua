local keymap = vim.keymap

local format_prettier = function()
   return {
     exe = "prettier",
     args = {
       "--stdin-filepath",
       vim.api.nvim_buf_get_name(0),
       "--parser",
       "html",
     },
     stdin = true
   }
end

local function get_visual_selection()
    -- Yank current visual selection into the 'v' register
    --
    -- Note that this makes no effort to preserve this register
    vim.cmd('noau normal! "vy"')

    return vim.fn.getreg('v')
end

-- 1. Run this query to get the start tag at the location of the cursor.
-- 2. Pass the start tag to prettier.
-- 3. Replace the attribute value range with the formatted value of the attribute value.
local html_tags_with_classes = vim.treesitter.parse_query(
  "html",
  [[
    (
      (start_tag
        (attribute
          (attribute_name) @name)
          (quoted_attribute_value (attribute_value) @value)) @start_tag
      (#eq? @name "class")
    )
  ]]
)

local get_root = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, "eruby", {})
  local tree = parser:parse()[1]
  return tree:root()
end

local format_selection = function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= "eruby" then
    vim.notify("Not an erb file")
    return
  end

  local root = get_root(bufnr)

  local changes = {}

  for pattern, match, _ in html_tags_with_classes:iter_matches(root, bufnr, 0, -1) do
    local start_tag = nil;
    local class_attributes = nil;
    for id, node in pairs(match) do
      local name = html_tags_with_classes.captures[id]
      if name == "start_tag" then
        start_tag = node
      end
    end

    -- { start_row, start_col, end_row, end_col }
    local range = { node:range() }

    local text = vim.treesitter.get_node_text(start_tag, bufnr)
    local formatted = vim.fn.system("prettier --parser html", text)
    P(formatted)
    html_tags_with_classes:iter_captures(root, bufnr, 0, -1)

    -- Keep track of changes
    --   but insert them in reverse order of the file
    --   so that when we make modifications, we don't have
    --   any out of date line numbers
    table.insert(changes, 1, {
      start_row = range[1] + 1,
      start_col = range[2],
      end_row = range[3] + 1,
      end_col = range[4],
      formatted = formatted,
    })
  end


end

-- keymap.set("n", "<leader>F", format_selection, { silent = true })
