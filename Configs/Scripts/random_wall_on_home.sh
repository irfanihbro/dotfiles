#!/usr/bin/env bash

WALL_DIR="$HOME/Wallpapers"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_queue"
LAST="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_last"

if [[ ! -s "$CACHE" ]]; then
    find "$WALL_DIR" -type f | shuf > "$CACHE"
fi

read -r WALL < "$CACHE"

if [[ -f "$LAST" ]] && [[ "$WALL" == "$(cat "$LAST")" ]] && [[ $(wc -l < "$CACHE") -gt 1 ]]; then
    tail -n +2 "$CACHE" > "$CACHE.tmp"
    echo "$WALL" >> "$CACHE.tmp"
    mv "$CACHE.tmp" "$CACHE"
    read -r WALL < "$CACHE"
fi

tail -n +2 "$CACHE" > "$CACHE.tmp" && mv "$CACHE.tmp" "$CACHE"
echo "$WALL" > "$LAST"

types=(wipe any)
chosen=${types[$RANDOM % ${#types[@]}]}

ffmpeg -y -i "$WALL" -vf \
"split[orig][blur]; \
[blur]crop=iw*0.35:ih:0:0,gblur=sigma=80,eq=brightness=-0.05[bleft]; \
[orig][bleft]overlay=0:0" \
/home/irfan/.cache/wallpaper_cache/partial_blur.jpg

awww img "$WALL" --transition-type "$chosen" --transition-fps 60 --transition-bezier 0.33,1.0,0.68,1.0 --transition-duration 1.6

NIRI_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_cache"
mkdir -p "$NIRI_DIR"
NIRI="$NIRI_DIR/blurred_wall.jpg"

if pgrep -x niri >/dev/null; then
  ffmpeg -y -hwaccel vaapi -i "$WALL" -vf "format=yuv420p,boxblur=20:5,eq=contrast=1.1:saturation=1.8" "$NIRI"
  awww img --namespace niri "$NIRI" --transition-type "$chosen" --transition-fps 60 --transition-bezier 0.33,1.0,0.68,1.0 --transition-duration 1.6
fi

sleep 1 && notify-send "Wallpaper changed" "$(basename "$WALL")" -i "$WALL"
