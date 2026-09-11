#!/bin/bash

status=$(playerctl -p spotify status 2>/dev/null)

if [[ "$status" != "Playing" && "$status" != "Paused" ]]; then
    printf '  Nothing playing\n'
    exit 0
fi

song_info=$(playerctl -p spotify metadata --format '{{ artist }} - {{ title }}' 2>/dev/null)

if [[ -n "$song_info" ]]; then
    if [[ "$status" == "Paused" ]]; then
        printf '  Paused: %s\n' "$song_info"
    else
        printf '  %s\n' "$song_info"
    fi
else
    printf '  Nothing playing\n'
fi
