if $(eza &>/dev/null)
then
  alias ls="eza -xF --group-directories-first"
  alias l="eza -lF --group-directories-first --no-time"
  alias ll="eza -laF --group-directories-first --no-time"
else
  alias ll="ls -AhlF --color"
  alias l="ls -hlF --color"
fi

