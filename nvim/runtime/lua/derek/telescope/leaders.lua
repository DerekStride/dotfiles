local keymap = vim.keymap
local functions = require('derek.telescope.functions')

keymap.set("n", "<C-p>", functions.default_finder, { noremap = true, silent = true })
keymap.set("n", "<leader>ff", functions.default_grep, { noremap = true, silent = true })
keymap.set("n", "<leader>fw", functions.grep_string, { noremap = true, silent = true })

keymap.set("n", "<leader>fh", functions.help_tags, { noremap = true, silent = true })
keymap.set("n", "<leader>fs", functions.treesitter, { noremap = true, silent = true })
keymap.set("n", "<leader>fb", functions.buffers, { noremap = true, silent = true })
keymap.set("n", "<leader>fB", functions.builtin, { noremap = true, silent = true })

keymap.set("n", "<leader>fj", functions.storefront_renderer, { noremap = true, silent = true })
keymap.set("n", "<leader>fp", functions.github_projects, { noremap = true, silent = true })
keymap.set("n", "<leader>fd", functions.dotfiles, { noremap = true, silent = true })
keymap.set("n", "<leader>fn", functions.notes, { noremap = true, silent = true })
