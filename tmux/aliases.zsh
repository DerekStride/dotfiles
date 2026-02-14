alias tmux-vsplit="tmux split-window -h -l 100"
alias tmux-split="tmux split-window -l 15"

alias wt='work new'

mux-dot() {
  tmux has-session -t main-terminal 2>/dev/null || tmux new-session -d -s main-terminal -n primary
  tmux has-window -t main-terminal:dot 2>/dev/null || tmux new-window -t main-terminal: -n dot -c "$ZSH" -d
  [ -n "$NOTES" ] && { tmux has-window -t main-terminal:notes 2>/dev/null || tmux new-window -t main-terminal: -n notes -c "$NOTES" -d; }
  tmux has-window -t main-terminal:site 2>/dev/null || tmux new-window -t main-terminal: -n site -c "$PROJECTS/github.com/derekstride/derekstride.github.io" -d
}

mux-sfr() {
  local storefront="$HOME/world/trees/root/src/areas/core/storefront"
  tmux has-session -t sfr 2>/dev/null || tmux new-session -d -s sfr -n primary -c "$storefront"
  tmux has-session -t shop 2>/dev/null || tmux new-session -d -s shop -n primary -c "$storefront"
}

