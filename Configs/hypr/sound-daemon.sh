#!/bin/bash
SOUNDS=~/.local/share/sounds

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    case "$line" in
        openwindow*)
            pw-play "$SOUNDS/scifi-popup.wav" &
            ;;
        closewindow*)
            pw-play "$SOUNDS/scifi-close.wav" &
            ;;
    esac
done
