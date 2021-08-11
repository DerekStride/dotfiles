local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then return end

local builtin = require('telescope.builtin')

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

    mappings = {
      i = {
        ["<C-x>"] = false,
        ["<esc>"] = actions.close,
      },
    },

    layout_config = {
      horizontal = {
        preview_width = 0.6,
      },
      prompt_position = "top",
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

function M.sonic_framework()
  builtin.find_files {
    prompt_title = "~ Sonic ~",
    shorten_path = false,
    cwd = "$HOME/src/github.com/Shopify/storefront-renderer/gems/sonic",

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
