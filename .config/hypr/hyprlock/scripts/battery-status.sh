#!/usr/bin/env bash

for capacity in /sys/class/power_supply/BAT*/capacity; do
    [[ -f "$capacity" ]] || continue
    value=$(<"$capacity")
    status_file="${capacity%capacity}status"
    status=""
    [[ -f "$status_file" ]] && status=$(<"$status_file")

    if [[ "$status" == "Charging" ]]; then
        if (( value < 20 )); then
            icon="󱊤"
        elif (( value < 60 )); then
            icon="󱊥"
        else
            icon="󱊦"
        fi
    elif (( value < 20 )); then
        icon="󱊡"
    elif (( value < 60 )); then
        icon="󱊢"
    else
        icon="󱊣"
    fi

    printf '%s %s%%' "$icon" "$value"
    exit 0
done

printf '󰂑 --'
