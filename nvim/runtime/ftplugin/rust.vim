nnoremap <buffer> <leader>rt :call VimuxRunCommand("clear; cargo test " . expand('<cword>'))<CR>
nnoremap <buffer> <leader>rf :call VimuxRunCommand("clear; cargo test " . expand('%:t:r'))<CR>
nnoremap <buffer> <leader>ra :call VimuxRunCommand("clear; cargo test")<CR>

augroup lsp_conifg do
  au!
  au BufEnter,BufWinEnter,TabEnter *.rs :lua require('lsp_extensions').inlay_hints{}
augroup END
