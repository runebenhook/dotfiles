#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
MASK="$THUMB_DIR/.mask.png"
mkdir -p "$THUMB_DIR"

shopt -s nullglob

[ -f "$MASK" ] || magick -size 240x135 xc:none -draw "roundrectangle 0,0,240,135,14,14" "$MASK"

for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
    name=$(basename "$img")
    thumb="$THUMB_DIR/${name%.*}.jpg"

    if [ ! -f "$thumb" ]; then
        magick "$img" \
            -strip \
            -colorspace sRGB \
            -resize 240x135^ \
            -gravity center \
            -extent 240x135 \
            -quality 88 \
            "$thumb"
    fi
done

entries=""

for img in "$WALLPAPER_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
    name=$(basename "$img")
    thumb="$THUMB_DIR/${name%.*}.jpg"

    printf -v entry 'img:%s:text:%s\n' "$thumb" "$name"
    entries+="$entry"
done

selected=$(wofi \
    --dmenu \
    --prompt "Buscar wallpaper..." \
    --conf ~/.config/wofi/wallpaper-config \
    --style ~/.config/wofi/wallpaper-style.css \
    <<< "$entries")

[ -z "$selected" ] && exit 0

filename=$(echo "$selected" | sed 's/^.*:text://')
target="$WALLPAPER_DIR/$filename"

ln -f "$target" "$HOME/.config/hypr/hyprlock-wallpaper"

awww img "$target" --transition-type grow --transition-duration 1.2 --transition-fps 60 --transition-bezier 0.23,1,0.32,1 --transition-pos "0.5,0.5"
wallust run "$target"

# Aplicar colores dinámicos a Hyprland
hyprctl reload >/dev/null 2>&1

# Reiniciar Waybar para aplicar la nueva paleta
pkill waybar 2>/dev/null
waybar >/dev/null 2>&1 &

# Recargar colores de Kitty en ventanas abiertas
kitty @ --to unix:/tmp/kitty set-colors ~/.config/kitty/colors.conf 2>/dev/null

STATE_DIR="$HOME/.local/state/wallpaper"
mkdir -p "$STATE_DIR"

printf '%s\n' "$target" > "$STATE_DIR/current"
