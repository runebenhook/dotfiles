#!/usr/bin/env bash

cpu=$(ps -A -o %cpu= | awk -v n="$(nproc)" '{s+=$1} END {printf "%d", s/n+0.5}')

ram=$(free | awk '/^Mem:/ {
    printf "%d", ($3/$2)*100+0.5
}')

bat="--"

for b in /sys/class/power_supply/BAT*; do
    if [ -r "$b/capacity" ]; then
        bat=$(cat "$b/capacity")
        break
    fi
done

printf '󰻠 %s%%    󰍛 %s%%    󰁹 %s%%' "$cpu" "$ram" "$bat"
