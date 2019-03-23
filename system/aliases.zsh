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

if [[ -d "/usr/local/var/postgres" ]]; then
  alias psql_start='pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start'
  alias psql_stop='pg_ctl -D /usr/local/var/postgres stop -s -m fast'
 fi
