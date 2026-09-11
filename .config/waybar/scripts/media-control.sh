#!/bin/bash

status="$(playerctl status 2>/dev/null || true)"

case "$status" in
    Playing)
        icon="󰏤"
        class="playing"
        tooltip="Pause"
        ;;
    Paused)
        icon="󰐊"
        class="paused"
        tooltip="Play"
        ;;
    *)
        icon="󰐊"
        class="stopped"
        tooltip="No media playing"
        ;;
esac

printf '{"text":"%s","class":"%s","tooltip":"%s"}\n' "$icon" "$class" "$tooltip"
