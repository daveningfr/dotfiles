#!/bin/sh
# Output: <percent>|<muted 0/1>
wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null |
    awk '{ v = $2 * 100; m = ($3 == "[MUTED]") ? 1 : 0; printf "%d|%d", v, m }'
