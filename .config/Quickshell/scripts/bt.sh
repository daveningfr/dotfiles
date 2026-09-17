#!/bin/sh
# Output: <power on/off>|<connected count>|<first device name>
powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{ print $2; exit }')

if [ "$powered" != "yes" ]; then
    printf 'off|0|'
    exit 0
fi

connected=$(bluetoothctl devices Connected 2>/dev/null)
count=$(printf '%s' "$connected" | grep -c .)
name=$(printf '%s' "$connected" | head -n1 | sed 's/^Device [^ ]* //')

printf 'on|%s|%s' "$count" "$name"
