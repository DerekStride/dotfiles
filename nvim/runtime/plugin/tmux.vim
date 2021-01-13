"auto reload files, :checktime will reload the file.
"if using vim inside tmux this requires setting focus-events in your .tmux.conf with:
"set -g focus-events on
augroup tmux_integration do
  au!
  au FocusGained * :checktime
augroup END
