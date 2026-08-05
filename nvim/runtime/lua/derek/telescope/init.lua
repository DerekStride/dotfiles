require('derek.telescope.leaders')

local telescope = require('telescope')

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
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
    },
  },
}

telescope.load_extension('fzf')
