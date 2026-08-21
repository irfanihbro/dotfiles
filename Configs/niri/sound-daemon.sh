#!/bin/bash
SOUNDS=~/.local/share/sounds
declare -A seen

niri msg --json event-stream | while read -r line; do
    if opened=$(echo "$line" | jq -e '.WindowOpenedOrChanged.window.id' 2>/dev/null); then
        if [[ -z "${seen[$opened]}" ]]; then
            seen[$opened]=1
            pw-play "$SOUNDS/scifi-popup.wav" &
        fi
    elif closed=$(echo "$line" | jq -e '.WindowClosed.id' 2>/dev/null); then
        unset "seen[$closed]"
        pw-play "$SOUNDS/scifi-close.wav" &
    fi
done
