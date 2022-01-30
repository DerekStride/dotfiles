nnoremap <buffer> <leader>rt :call VimuxRunCommand("cargo test " . expand('<cword>'))<CR>
nnoremap <buffer> <leader>rf :call VimuxRunCommand("cargo test " . expand('%:t:r'))<CR>
nnoremap <buffer> <leader>ra :call VimuxRunCommand("cargo test")<CR>

augroup lsp_conifg do
  au!
  au BufEnter,BufWinEnter,BufWritePost,TabEnter *.rs :lua require('lsp_extensions').inlay_hints{ enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
augroup END
