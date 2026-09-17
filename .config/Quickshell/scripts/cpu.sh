#!/bin/sh
# Output: <usage percent>
s1=$(awk '/^cpu /{ print $2 + $4, $2 + $4 + $5; exit }' /proc/stat)
sleep 0.4
s2=$(awk '/^cpu /{ print $2 + $4, $2 + $4 + $5; exit }' /proc/stat)
echo "$s1 $s2" | awk '{
    dt = $4 - $2
    if (dt <= 0) { print 0; exit }
    printf "%d", ($3 - $1) / dt * 100
}'
