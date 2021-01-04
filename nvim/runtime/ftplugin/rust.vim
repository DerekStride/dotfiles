nnoremap <buffer> <leader>rt :!cargo test <cword><CR>
nnoremap <buffer> <leader>rf :!cargo test %:t:r<CR>
nnoremap <buffer> <leader>ra :!cargo test<CR>

augroup lsp_conifg do
  au!
  au BufEnter,BufWinEnter,TabEnter *.rs :lua require('lsp_extensions').inlay_hints{}
augroup END
