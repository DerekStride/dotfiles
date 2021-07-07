local has_telescope, telescope = pcall(require, 'telescope')
local builtin = require('telescope.builtin')

if not has_telescope then return end

local should_reload = false
local reloader = function()
  if should_reload then
    RELOAD('plenary')
    RELOAD('popup')
    RELOAD('telescope')
  end
end

reloader()

local actions = require('telescope.actions')
local sorters = require('telescope.sorters')

telescope.setup {
  defaults = {
    prompt_prefix = ' > ',

    sorting_strategy = "ascending",
    prompt_position = "top",

    mappings = {
      i = {
        ["<C-x>"] = false,
        ["<esc>"] = actions.close,
      },
    },

    layout_defaults = {
      horizontal = {
        preview_width = 0.6,
      },
    },

    file_sorter = sorters.get_fzy_sorter,
    vimgrep_arguments = {
      'rg',
      '--column',
      '--line-number',
      '--no-heading',
      '--color=never',
      '--smart-case'
    },
  },

  extensions = {
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },

    fzf_writer = {
      use_highlighter = false,
      minimum_grep_characters = 4,
    },
  },
}

telescope.load_extension('fzy_native')

local M = {}

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

function M.storefront_gql()
  builtin.find_files {
    prompt_title = "~ storefront gQL ~",
    shorten_path = false,
    cwd = "$HOME/src/github.com/Shopify/storefront-renderer/storefront-graphql",

    layout_config = {
      preview_width = 0.6,
    },
  }
end

return setmetatable({}, {
  __index = function(_, k)
    reloader()

    if M[k] then
      return M[k]
    else
      return builtin[k]
    end
  end
})
