local actions = require('telescope.actions')
local sorters = require('telescope.sorters')

require('telescope').setup {
  defaults = {
    prompt_prefix = ' > ',

    layout_strategy = 'horizontal',
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    scroll_strategy = "cycle",
    prompt_position = "top",

    mappings = {
      i = {
        ["<C-x>"] = false,
        ["<esc>"] = actions.close,
      },
    },

    file_sorter = sorters.get_fzy_sorter,
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
