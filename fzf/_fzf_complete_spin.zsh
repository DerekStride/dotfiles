_fzf_complete_spin() {
  which spin > /dev/null 2>&1 || return
  _fzf_complete --prompt="spin> " -- "$@" < <(
      spin list | sed 1,2d
  )
}

_fzf_complete_spin_post() {
  which spin > /dev/null 2>&1 || return
  awk '{print $1}'
}
