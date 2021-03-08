local actions = require('telescope.actions')
local sorters = require('telescope.sorters')

require('telescope').setup {
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

    file_sorter = sorters.get_fzy_sorter,
    vimgrep_arguments = {'rg', '--column', '--line-number', '--no-heading', '--color=never', '--smart-case'}
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

require('telescope').load_extension('fzy_native')
