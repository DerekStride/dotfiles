# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias ll="gls -AhlF --color"
  alias l="gls -hlF --color"
else
  alias ll="ls -AhlF --color"
  alias l="ls -hlF --color"
fi

