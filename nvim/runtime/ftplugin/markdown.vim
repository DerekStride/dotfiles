augroup dereks_markdown_settings do
  au!
  au BufEnter,BufWinEnter,TabEnter *.md :setlocal wrap linebreak nolist textwidth=120
augroup END

