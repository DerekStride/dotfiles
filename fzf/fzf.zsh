export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git'"
export FZF_DEFAULT_OPTS="--multi --reverse --no-mouse --height=50% --preview 'bat --style=numbers,changes --color always {} 2> /dev/null' --bind='f2:toggle-preview'"

