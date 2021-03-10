hi! link TelescopeSelectionCaret DraculaPink
hi! link TelescopeMatching DraculaGreen

nnoremap <silent> <C-p> <cmd>lua require('telescope.builtin').find_files({find_command = {'rg', '--files'}, hidden = true, follow = true})<cr>
nnoremap <silent> <leader>fp <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <silent> <leader>ff <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <silent> <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <silent> <leader>fB <cmd>lua require('telescope.builtin').builtin()<cr>
nnoremap <silent> <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <silent> <leader>fs <cmd>lua require('telescope.builtin').treesitter()<cr>
