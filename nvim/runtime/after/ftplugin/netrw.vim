" Keep netrw's refresh from shadowing herdr's forwarded <C-l>.
nmap <buffer> <silent> <leader>r <Plug>NetrwRefresh
silent! nunmap <buffer> <C-l>
