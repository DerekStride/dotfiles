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

nnoremap <silent> <leader>x :so %<CR>
nnoremap <silent> <leader><leader>x :luafile %<CR>

"notes
nnoremap <silent> <leader>ns :wincmd s<bar> :e $SCRATCH/scratch.md<CR>
nnoremap <silent> <leader>nt :wincmd s<bar> :e $SCRATCH/todo.md<CR>
nnoremap <silent> <leader><leader>n :wincmd s<bar> :e $SCRATCH<CR>

" quickfix
nnoremap <silent> <C-j> :cnext<CR>
nnoremap <silent> <C-k> :cprev<CR>
nnoremap <silent> <leader>q :call ToggleQFList(1)<CR>

let g:the_primeagen_qf_l = 0
let g:the_primeagen_qf_g = 0

fun! ToggleQFList(global)
  if a:global
    if g:the_primeagen_qf_g == 1
      let g:the_primeagen_qf_g = 0
      cclose
    else
      let g:the_primeagen_qf_g = 1
      copen
    end
  else
    if g:the_primeagen_qf_l == 1
      let g:the_primeagen_qf_l = 0
      lclose
    else
      let g:the_primeagen_qf_l = 1
      lopen
    end
  endif
endfun
