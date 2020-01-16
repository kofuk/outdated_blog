#!/usr/bin/env bash

if [ $# -lt 1 ]; then
    echo 'An argument expected.' >&2
fi

src_dir="$(cd "$(dirname "${BASH_SOURCE:-$0}")"; pwd)"
cat "$(find "$src_dir/../$1" -maxdepth 1 -mindepth 1 | head -n 1)" | head -n 1 | \
    sed -E 's/#\+TITLE:[ ]+//' | tr -d '#'
