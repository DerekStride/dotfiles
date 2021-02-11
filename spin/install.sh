#!/usr/bin/env bash
#
# Install dependencies on spin machine

if [ -z $SPIN ]
then
  exit 0
fi

set -e

# Install neovim 0.5
curl -L https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage -o /tmp/nvim.appimage
chmod +x /tmp/nvim.appimage
/tmp/nvim.appimage --appimage-extract
[ -d /squashfs-root ] || sudo mv squashfs-root /
[ -f /usr/bin/nvim ] || sudo ln -s /squashfs-root/AppRun /usr/bin/nvim

# Install fzf and bat
sudo apt-get install -y fzf bat
[ -f /usr/local/bin/bat ] || sudo ln -s $(which batcat) /usr/local/bin/bat

# Install ripgrep
curl -L https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb -o /tmp/ripgrep.deb
sudo dpkg -i /tmp/ripgrep.deb
