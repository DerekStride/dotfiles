#!/usr/bin/env bash
#
# macos doesn't install the latest terminfo thingy's so this will install the ones for alacritty and tmux
# source: https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95

if test ! "$(uname)" = "Darwin"
then
  exit 0
fi

set -e

if [ ! -f /tmp/terminfo.src ]
then
  curl -L https://invisible-island.net/datafiles/current/terminfo.src.gz -o /tmp/terminfo.src.gz && gunzip /tmp/terminfo.src
fi

if ! infocmp -x tmux-256color > /dev/null 2>&1
then
  sudo tic -xe tmux-256color /tmp/terminfo.src > /dev/null 2>&1 && echo "tmux-256color terminfo installed" || echo "error installing tmux-256color terminfo"
fi

if ! infocmp -x alacritty-direct > /dev/null 2>&1
then
  sudo tic -xe alacritty-direct /tmp/terminfo.src > /dev/null 2>&1 && echo "alacritty-direct terminfo installed" || echo "error installing alacritty-direct terminfo"
fi

if ! infocmp -x alacritty > /dev/null 2>&1
then
  sudo tic -xe alacritty /tmp/terminfo.src > /dev/null 2>&1 && echo "alacritty terminfo installed" || echo "error installing alacritty terminfo"
fi

