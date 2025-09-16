"This is to get around the symlink filetype in my dotfiles
augroup dotfiles do
  au!
  au BufEnter *.lua.symlink :set filetype=lua
augroup END

augroup rbs do
  au!
  au BufEnter *.rbs :set filetype=ruby
augroup END
