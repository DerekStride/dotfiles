# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias ll="gls -AhlF --color"
  alias l="gls -hlF --color"
  alias la='gls -ahlF --color'
fi

