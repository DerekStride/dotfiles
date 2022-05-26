if $(exa &>/dev/null)
then
  alias ls="exa -xF --group-directories-first"
  alias l="exa -lF --group-directories-first --no-time"
  alias ll="exa -laF --group-directories-first --no-time"
else
  alias ll="ls -AhlF --color"
  alias l="ls -hlF --color"
fi

