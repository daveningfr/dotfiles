#!/usr/bin/env bash

set -u

state_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-battery-notification"
event="${1:-}"
state=""

[[ -f "$state_file" ]] && state=$(<"$state_file")

case "$event" in
    full)
        [[ "$state" == "full" ]] && exit 0
        notify-send -u normal "Battery Full" "Battery reached 100%."
        printf '%s\n' full > "$state_file"
        ;;
    critical)
        [[ "$state" == "critical" ]] && exit 0
        notify-send -u critical "Very Low Battery" "Connect your charger soon."
        printf '%s\n' critical > "$state_file"
        ;;
esac
