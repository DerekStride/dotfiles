"This is to get around the symlink filetype in my dotfiles
augroup dotfiles do
  au!
  au BufEnter *.vim.symlink :set filetype=vim
augroup END
