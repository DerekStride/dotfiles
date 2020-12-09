function! RunRubyTests(all_tests)
  if executable("/opt/dev/bin/dev")
    if a:all_tests
      echo system("/opt/dev/bin/dev test")
      return
    endif
    let command = "/opt/dev/bin/dev test "
  else
    if a:all_tests
      echo system("bundle exec rake test")
      return
    endif
    let command = "bundle exec ruby -Itest "
  endif

  echo system(command . bufname("%"))
endfunction

nmap <buffer> <leader>rf :call RunRubyTests(0)<CR>
nmap <buffer> <leader>ra :call RunRubyTests(1)<CR>
