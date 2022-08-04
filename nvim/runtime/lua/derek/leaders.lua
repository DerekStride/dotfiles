local keymap = vim.keymap
local default_opts = { silent = true, noremap = true }

keymap.set("n", "<leader><leader>m", "<cmd>!mux split<cr><cr>", default_opts)
