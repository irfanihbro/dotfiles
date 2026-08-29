#!/bin/bash
FOOT_CONF="$HOME/.config/foot/foot_for_smassh.ini"

if command -v smassh &>/dev/null; then
  foot --fullscreen --config $FOOT_CONF --app-id smassh -e smassh
else
  notify-send "Smassh not found" "Please install smassh"
fi
