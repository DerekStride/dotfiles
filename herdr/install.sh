#!/usr/bin/env bash

set -e

if ! command -v herdr >/dev/null 2>&1
then
  exit 0
fi

plugins="$(herdr plugin list --plugin herdr-nvim-nav --json)"
case "$plugins" in
  *'"plugin_id":"herdr-nvim-nav"'*) exit 0 ;;
esac

herdr plugin install aimdevlee/herdr-nvim-nav --ref ec047fd6d8d0269d54a34e9405af28d8aad4c8f0 --yes
