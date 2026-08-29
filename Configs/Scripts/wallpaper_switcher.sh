#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper_thumbs"
ROFI_THEME="$HOME/.config/rofi/wallpaper-selector.rasi"
MAPPING_FILE="/tmp/wallpaper_mapping_$$"
LAST="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_last"

mkdir -p "$THUMB_DIR"
trap 'rm -f "$MAPPING_FILE"' EXIT

collect_images() {
    shopt -s nullglob nocaseglob
    for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,webp,bmp,gif}; do
        [[ -f "$img" ]] && printf '%s\n' "$img"
    done
    shopt -u nullglob nocaseglob
}

needs_thumbnails() {
    while IFS= read -r img; do
        local name thumb
        name=$(basename "${img%.*}")
        thumb="$THUMB_DIR/${name}_thumb.png"
        [[ ! -f "$thumb" || "$img" -nt "$thumb" ]] && return 0
    done < <(collect_images)
    return 1
}

generate_thumbnails() {
    while IFS= read -r img; do
        local name thumb
        name=$(basename "${img%.*}")
        thumb="$THUMB_DIR/${name}_thumb.png"
        if [[ ! -f "$thumb" || "$img" -nt "$thumb" ]]; then
            ffmpeg -y -i "$img" \
                -vf "scale=480:270:force_original_aspect_ratio=increase,crop=480:270" \
                -frames:v 1 "$thumb" &>/dev/null
        fi
    done < <(collect_images)
}

build_rofi_input() {
    : > "$MAPPING_FILE"
    while IFS= read -r img; do
        local filename name thumb
        filename=$(basename "$img")
        name="${filename%.*}"
        thumb="$THUMB_DIR/${name}_thumb.png"

        printf '%s\t%s\n' "$name" "$img" >> "$MAPPING_FILE"

        if [[ -f "$thumb" ]]; then
            printf '%s\x00icon\x1f%s\n' "$name" "$thumb"
        else
            printf '%s\n' "$name"
        fi
    done < <(collect_images)
}

if needs_thumbnails; then
    echo "Generating thumbnails…" | rofi -dmenu \
        -p "" \
        -no-custom \
        -theme "$ROFI_THEME" \
        -theme-str 'listview { lines: 0; } inputbar { enabled: false; }' \
        &>/dev/null &
    SPINNER_PID=$!

    generate_thumbnails

    kill "$SPINNER_PID" 2>/dev/null
    wait "$SPINNER_PID" 2>/dev/null
    sleep 0.1
fi

selection=$(build_rofi_input | rofi -dmenu -i \
    -p "" \
    -show-icons \
    -theme "$ROFI_THEME")

[[ -z "$selection" ]] && exit 0

selected_path=$(awk -F'\t' -v sel="$selection" '$1 == sel { print $2; exit }' "$MAPPING_FILE")

if [[ ! -f "$selected_path" ]]; then
    echo "Error: resolved path not found — '$selected_path'"
    exit 1
fi

echo "$selected_path" > "$LAST"

QUEUE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_queue"
if [[ -s "$QUEUE" ]]; then
    head_wall=$(head -n 1 "$QUEUE")
    if [[ "$head_wall" == "$selected_path" ]]; then
        tail -n +2 "$QUEUE" > "$QUEUE.tmp" && mv "$QUEUE.tmp" "$QUEUE"
    fi
fi

types=(wipe any)
chosen=${types[$RANDOM % ${#types[@]}]}

ffmpeg -y -i "$selected_path" -vf \
"split[orig][blur]; \
[blur]crop=iw*0.35:ih:0:0,gblur=sigma=80,eq=brightness=-0.10[bleft]; \
[orig][bleft]overlay=0:0" \
/home/irfan/.cache/wallpaper_cache/partial_blur.jpg

awww img "$selected_path" --transition-type "$chosen" --transition-fps 60 --transition-bezier 0.33,1.0,0.68,1.0 --transition-duration 1.6

NIRI_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper_cache"
mkdir -p "$NIRI_DIR"
NIRI="$NIRI_DIR/blurred_wall.jpg"

if pgrep -x niri >/dev/null; then
  ffmpeg -y -hwaccel vaapi -i "$selected_path" -vf "format=yuv420p,boxblur=20:5,eq=contrast=1.1:saturation=1.8" "$NIRI"
  awww img --namespace niri "$NIRI" --transition-type "$chosen" --transition-fps 60 --transition-bezier 0.33,1.0,0.68,1.0 --transition-duration 1.6
fi

sleep 1 && notify-send "Wallpaper changed" "$(basename "$selected_path")" -i "$selected_path"
