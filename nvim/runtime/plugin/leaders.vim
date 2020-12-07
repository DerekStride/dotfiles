"move line up or down .+1 - current line +1 \ == re-indent to match area
nnoremap <silent> <leader>J :m .+1<CR>==
nnoremap <silent> <leader>K :m .-2<CR>==
"turn off highlights
nnoremap <silent> <leader>nh :noh<CR>

"move between windows
nnoremap <silent> <leader>h :wincmd h<CR>
nnoremap <silent> <leader>j :wincmd j<CR>
nnoremap <silent> <leader>k :wincmd k<CR>
nnoremap <silent> <leader>l :wincmd l<CR>
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

"notes
nnoremap <silent> <leader>ns :wincmd s<bar> :e ~/Dropbox/Documents/Work/Shopify/notes/scratch.md<CR>
nnoremap <silent> <leader>nr :wincmd s<bar> :e ~/Dropbox/Documents/Work/Shopify/notes/rare-vim-commands.md<CR>
nnoremap <silent> <leader>nt :wincmd s<bar> :e ~/Dropbox/Documents/Work/Shopify/notes/vim-tool-sharpening.md<CR>
