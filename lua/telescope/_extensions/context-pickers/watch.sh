#!/bin/bash

while inotifywait -e close_write --recursive ./ || true; do
  clear
  lua ./list.lua | bat -l lua -p
  echo -e "\n--"
  luacheck ./*.lua ./pickers/*.lua
done
