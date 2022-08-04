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
    fzy_native = {
      override_generic_sorter = false,
      override_file_sorter = true,
    },
  },
}

telescope.load_extension('fzy_native')
