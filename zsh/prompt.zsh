autoload colors && colors

# If the current path, with prefix replacement, has 3 or more elements `%3~`
# then return the directory we're in `%1/` else return the whole path `%2~`.
#
# The `~` in `%3~` means the current working directory but if it starts with
# $HOME, that part is replaced by a ‘~’. Changing it to `%3/` would not do the
# substitution, like we do with `%1/`.
directory_name() {
  echo "%{$fg_bold[blue]%}%(3~|%1/|%2~)%{$reset_color%} "
}

prompt_arrow() {
  echo "%{$fg_bold[green]%}➜%{$reset_color%} "
}

prompt_machine_info() {
  if [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]] || (( EUID == 0 )); then
    echo "%{$fg_bold[magenta]%}%n%{$reset_color%} "
  fi
}

export PROMPT=$'$(prompt_arrow)$(prompt_machine_info)$(directory_name)'
