#!/usr/bin/env bash
#
# Install vim-plug

INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_PATH=$INSTALL_DIR/nvim/site/pack/packer/start/packer.nvim

if [ ! -e $INSTALL_PATH ]
then
  git clone https://github.com/wbthomason/packer.nvim $INSTALL_PATH
  nvim --headless +PackerCompile +PackerInstall +qall > /dev/null 2>&1
fi
