#!/bin/sh
# Output: <type>|<connection name>
nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | awk -F: '
    $2 == "connected" && ($1 == "wifi" || $1 == "ethernet") { print $1 "|" $3; found = 1; exit }
    END { if (!found) print "none|disconnected" }
'
