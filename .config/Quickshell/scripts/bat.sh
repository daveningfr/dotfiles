#!/bin/sh
# Output: <capacity>|<status>
for dir in /sys/class/power_supply/BAT*; do
    [ -r "$dir/capacity" ] || continue
    printf '%s|%s' "$(cat "$dir/capacity")" "$(cat "$dir/status" 2>/dev/null)"
    exit 0
done

printf '|unknown'
