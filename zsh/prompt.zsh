autoload colors && colors

# If the current path, with prefix replacement, has 3 or more elements `%3~`
# then return the directory we're in `%1/` else return the whole path `%2~`.
#
# The `~` in `%3~` means the current working directory but if it starts with
# $HOME, that part is replaced by a ‘~’. Changing it to `%3/` would not do the
# substitution, like we do with `%1/`.
export PROMPT=$'%{$fg_bold[green]%}➜%{$reset_color%} %{$fg_bold[blue]%}%(3~|%1/|%2~)%{$reset_color%} '
