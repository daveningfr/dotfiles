#!/bin/sh
# Output: <dnd true/false>|<notification count>
printf '%s|%s' "$(swaync-client -D 2>/dev/null || printf false)" "$(swaync-client -c 2>/dev/null || printf 0)"
