#!/usr/bin/env bash
#
# Install vim-plug

INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_PATH=$INSTALL_DIR/nvim/site/autoload/plug.vim

if [ ! -e $INSTALL_PATH ]
then
  curl -fLo $INSTALL_PATH --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim --headless +PlugInstall +qall > /dev/null 2>&1
fi
