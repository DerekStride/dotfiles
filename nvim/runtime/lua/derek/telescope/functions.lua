local M = {}
local builtin = require('telescope.builtin')
local expand = vim.fn.expand

function M.dotfiles()
  builtin.find_files {
    prompt_title = "~ dotfiles ~",
    shorten_path = false,
    cwd = "$ZSH",

    layout_config = {
      preview_width = 0.6,
    },
  }
end

function M.storefront_renderer()
  builtin.find_files {
    prompt_title = "~ Storefront Renderer ~",
    shorten_path = false,
    cwd = "$HOME/src/github.com/Shopify/storefront-renderer",

    layout_config = {
      preview_width = 0.6,
    },
  }
end

function M.default_finder()
  builtin.find_files {
    find_command = {'rg', '--files'},
    hidden = true,
    follow = true
  }
end

function M.default_grep()
  builtin.live_grep {
    default_text = expand("<cword>"),
  }
end

function M.github_projects()
  builtin.find_files {
    prompt_title = "~ GitHub Products ~",
    shorten_path = true,
    cwd = "$PROJECTS/github.com/",
    find_command = {
      "filter-projects",
    },

    layout_config = {
      preview_width = 0.6,
    },
  }
end

return setmetatable({}, {
  __index = function(_, k)
    if M[k] then
      return M[k]
    else
      return builtin[k]
    end
  end
})
