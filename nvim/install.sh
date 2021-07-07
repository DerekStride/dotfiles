#!/usr/bin/env bash
#
# Install packer.nvim

INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_PATH=$INSTALL_DIR/nvim/site/pack/packer/start/packer.nvim

if [ ! -e $INSTALL_PATH ]
then
  git clone https://github.com/wbthomason/packer.nvim $INSTALL_PATH
  nvim --headless -c 'au! User PackerComplete :qa!' -c 'PackerSync'
fi
