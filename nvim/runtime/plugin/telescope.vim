hi! link TelescopeSelectionCaret DraculaPink
hi! link TelescopeMatching DraculaGreen

nnoremap <silent> <C-p> <cmd>lua require('derek/telescope').find_files({find_command = {'rg', '--files'}, hidden = true, follow = true})<cr>
nnoremap <silent> <leader>fp <cmd>lua require('derek/telescope').find_files()<cr>
nnoremap <silent> <leader>ff <cmd>lua require('derek/telescope').live_grep()<cr>
nnoremap <silent> <leader>fw <cmd>lua require('derek/telescope').grep_string()<cr>
nnoremap <silent> <leader>fd <cmd>lua require('derek/telescope').dotfiles()<cr>
nnoremap <silent> <leader>fb <cmd>lua require('derek/telescope').buffers()<cr>
nnoremap <silent> <leader>fB <cmd>lua require('derek/telescope').builtin()<cr>
nnoremap <silent> <leader>fh <cmd>lua require('derek/telescope').help_tags()<cr>
nnoremap <silent> <leader>fs <cmd>lua require('derek/telescope').treesitter()<cr>
