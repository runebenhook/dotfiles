#!/usr/bin/env bash

STATE="$HOME/.local/state/wallpaper/current"
FALLBACK="$HOME/Wallpapers/pixel_art.png"

# Esperar a que awww-daemon esté listo
for _ in {1..20}; do
    if awww query >/dev/null 2>&1; then
        break
    fi

    sleep 0.25
done

if [[ -f "$STATE" ]]; then
    target=$(<"$STATE")

    if [[ -f "$target" ]]; then
        awww img "$target"
	ln -f "$target" "$HOME/.config/hypr/hyprlock-wallpaper"
	wallust run "$target"

	# Aplicar la paleta a Waybar después del arranque
	sleep 0.5

       # Recargar Kitty si ya está disponible
	kitty @ --to unix:/tmp/kitty set-colors ~/.config/kitty/colors.conf 2>/dev/null

        exit 0
    fi
fi

if [[ -f "$FALLBACK" ]]; then
    awww img "$FALLBACK"
    ln -f "$FALLBACK" "$HOME/.config/hypr/hyprlock-wallpaper"
fi
