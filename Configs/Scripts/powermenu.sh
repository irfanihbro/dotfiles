#!/bin/bash

options="  Shutdown\n  Reboot\n  Suspend\n  Lock\n  Exit MangoWM"

chosen=$(printf "$options" | fzf \
  --prompt=" Powermenu: " \
  --reverse \
  # --border \
  --no-info \
  --height=40%)

case "$chosen" in
  *Shutdown) systemctl poweroff ;;
  *Reboot)   systemctl reboot ;;
  *Suspend)  systemctl suspend ; bash ~/.config/Scripts/random_wall_on_lockscr.sh ;;
  *Lock)     ~/.config/Scripts/random_wall_on_lockscr.sh ;;
  *Exit\ MangoWM)   pkill mango ;;
esac
