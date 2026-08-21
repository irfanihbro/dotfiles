#!/usr/bin/env bash

pkill rofi || \
cliphist list | \
rofi -dmenu \
     -display-columns 2 \
     -theme \~/.config/rofi/clipboard.rasi | \
cliphist decode | \
wl-copy
