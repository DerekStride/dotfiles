#!/usr/bin/env bash
#
# Install zk for managing a Zettelkasten.

if [ -z "$ZK_PATH" ]
then
  echo "Set \$ZK_PATH in ~/.localrc to the location of your Zettelkasten"
  exit 1
fi

ZK_INSTALL_DIR=$PROJECTS/github.com/sirupsen
ZK_INSTALL_PATH=$ZK_INSTALL_DIR/zk

set -ex

[[ ! -d $ZK_INSTALL_DIR ]] && mkdir $ZK_INSTALL_DIR

[[ ! -d $ZK_INSTALL_PATH ]] && git clone https://github.com/sirupsen/zk $ZK_INSTALL_PATH

git -C $ZK_INSTALL_PATH pull --rebase origin master

