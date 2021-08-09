"move line up or down .+1 - current line +1 \ = re-indent to match area
vnoremap <silent> J :m '>+1<CR>gv=gv
vnoremap <silent> K :m '<-2<CR>gv=gv
"turn off highlights
nnoremap <silent> <leader>nh :noh<CR>

"rotate windows
nnoremap <silent> <leader>H :wincmd H<CR>
nnoremap <silent> <leader>J :wincmd J<CR>
nnoremap <silent> <leader>K :wincmd K<CR>
nnoremap <silent> <leader>L :wincmd L<CR>

" yank to system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG
nnoremap <leader>p "+p

"open new tab with file explorer
nnoremap <silent> <leader>e :Explore<CR>
nnoremap <silent> <leader>t :tabe<CR>
nnoremap <silent> <leader>pv :wincmd v<bar> :Ex<bar> :vertical resize 30<CR>

nnoremap <silent> <leader>x :so %<CR>
nnoremap <silent> <leader><leader>x :luafile %<CR>

"notes
nnoremap <silent> <leader>ns :wincmd s<bar> :e ~/Dropbox/Documents/Work/Shopify/notes/scratch.md<CR>
nnoremap <silent> <leader>nr :wincmd s<bar> :e ~/Dropbox/Documents/Work/Shopify/notes/rare-vim-commands.md<CR>
nnoremap <silent> <leader>nw :wincmd s<bar> :e ~/Dropbox/Documents/Work/Shopify/notes/vim-tool-sharpening.md<CR>
nnoremap <silent> <leader>nt :wincmd s<bar> :e ~/Dropbox/Documents/Work/Shopify/notes/todo.md<CR>
