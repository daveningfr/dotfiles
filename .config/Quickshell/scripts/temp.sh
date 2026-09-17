#!/bin/sh
# Output: <package temperature in celsius>
for zone in /sys/class/thermal/thermal_zone*; do
    [ -r "$zone/type" ] || continue
    if [ "$(cat "$zone/type" 2>/dev/null)" = "x86_pkg_temp" ]; then
        awk '{ printf "%d", $1 / 1000 }' "$zone/temp"
        exit 0
    fi
done

# Fallback for machines without an x86_pkg_temp zone.
sensors 2>/dev/null | awk '/Package id 0/ { gsub(/[^0-9.]/, "", $4); printf "%d", $4; exit }'
