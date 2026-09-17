#!/bin/sh
# Output: <used percent>
#
# Uses MemAvailable rather than MemFree: MemFree excludes reclaimable page
# cache, so it reports a machine as almost fully used even when idle.
awk '
    /^MemTotal:/     { total = $2 }
    /^MemAvailable:/ { avail = $2 }
    END {
        if (total > 0)
            printf "%d", (total - avail) / total * 100
        else
            printf "0"
    }
' /proc/meminfo
