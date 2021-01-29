#!/usr/bin/env bash
#
# Install the lua language server for use with nvim-lsp.

if test ! "$(uname)" = "Darwin"
then
  exit 0
fi

LUA_LSP_DIR=$PROJECTS/github.com/sumneko
LUA_LSP_PATH=$LUA_LSP_DIR/lua-language-server

set -ex

#brew install ninja

[[ ! -d $LUA_LSP_DIR ]] && mkdir $LUA_LSP_DIR

[[ ! -d $LUA_LSP_PATH ]] && git clone https://github.com/sumneko/lua-language-server $LUA_LSP_PATH

git -C $LUA_LSP_PATH pull --rebase origin master

git -C $LUA_LSP_PATH submodule update --init --recursive

ninja -C $LUA_LSP_PATH/3rd/luamake -f ninja/macos.ninja

cd $LUA_LSP_PATH

./3rd/luamake/luamake rebuild
