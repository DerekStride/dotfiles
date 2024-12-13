augroup dereks_proto_settings do
  au!
  au BufEnter,BufWinEnter,TabEnter *.proto :setlocal wrap linebreak nolist textwidth=120 showbreak=+\ 
augroup END
