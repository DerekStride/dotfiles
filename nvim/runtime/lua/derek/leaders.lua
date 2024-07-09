local keymap = vim.keymap
local default_opts = { silent = true, noremap = true }

keymap.set("n", "<leader><leader>m", "<cmd>!mux split<cr><cr>", default_opts)
keymap.set("n", "<leader><leader>s", "<cmd>set nonumber<cr>", default_opts)
keymap.set("n", "<leader><leader>p", "<cmd>set number<cr>", default_opts)
