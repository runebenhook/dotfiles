#!/usr/bin/env bash

command -v playerctl >/dev/null 2>&1 || exit 0

playerctl metadata \
    --format '󰝚  {{ artist }} — {{ title }}' \
    2>/dev/null

