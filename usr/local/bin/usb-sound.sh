#!/bin/bash
# $1 = "in" atau "out"
USER_NAME="$(logname 2>/dev/null || who | awk 'NR==1{print $1}')"
USER_ID="$(id -u "$USER_NAME")"

export XDG_RUNTIME_DIR="/run/user/$USER_ID"
export PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native"

SOUND_FILE="/home/$USER_NAME/.local/share/sounds/usb-$1.wav"

sudo -u "$USER_NAME" XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" paplay "$SOUND_FILE"
