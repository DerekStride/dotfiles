function! ParseGitBlame()
  let command_output = system("git blame --porcelain " . bufname("%") . " | parse-git-blame.awk")
  "s/\e\[[0-9;]*m//g
  let scrubed_output = substitute(command_output, "\e\[[0-9;]*m", "", "g")

  "Open a new split and set it up.
  split __GitBlame_Output__
  normal! ggdG
  setlocal filetype=gitcommit
  setlocal buftype=nofile

  "Insert the git blame.
  call append(0, split(scrubed_output, '\v\n'))
endfunction
