"Ripgrep with FZF preview using bat
function! RipgrepFzf(query, fullscreen)
  if exists(a:query)
    let query = a:query
  else
    let query = expand('<cword>')
  endif

  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(query))

  "Let Ripgrep do the filtering and just use fzf for selecting -- disables the fuzzy matching.
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--preview', 'bat --style=numbers,changes --color always {}', '--query', query, '--bind', 'change:reload:'.reload_command]}

  "Ripgrep without searching the filenames
  "let spec = {'options': ['--delimiter', ':', '--nth', '4..', '--preview', 'bat --style=numbers,changes --color always {}', '--query', query]}

  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

"Define RG instead of overwriting Rg
command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

"fzf config
nnoremap <silent> <C-p> :Files<CR>
nnoremap <silent> <leader>zf :RG<CR>
nnoremap <silent> <leader>zb :Buffers<CR>
nnoremap <silent> <leader>zh :Helptags<CR>
nnoremap <silent> <leader>zy :History:<CR>
"run tags matching the current word jump directly if there is only one match
nnoremap <silent> <leader>zt :call fzf#vim#tags('^' . expand('<cword>'), {'options': '--exact --select-1 --exit-0 +i'})<CR>
