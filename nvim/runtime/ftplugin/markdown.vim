augroup dereks_markdown_settings do
  au!
  au BufEnter,BufWinEnter,TabEnter *.md :setlocal wrap linebreak nolist textwidth=120 showbreak=+\ 
augroup END

nmap <buffer> <leader>md :VimuxClearTerminalScreen <bar> call VimuxRunCommand("glow " . expand('%:p'))<cr>
nmap <buffer> <leader>mp :call VimuxRunCommand("glow -p " . expand('%:p'))<cr>
