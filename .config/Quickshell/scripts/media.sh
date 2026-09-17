#!/bin/sh
# Output: <progress 0..1>|<position>|<duration>|<status>~<artist>~<title>~<album>~<artUrl>
pos=$(playerctl position 2>/dev/null || printf 0)
len=$(playerctl metadata --format '{{mpris:length}}' 2>/dev/null || printf 0)
meta=$(playerctl metadata --format '{{status}}~{{artist}}~{{title}}~{{album}}~{{mpris:artUrl}}' 2>/dev/null)
[ -n "$meta" ] || meta="Stopped~~~~"

awk -v p="$pos" -v l="$len" -v m="$meta" 'BEGIN {
    d = l / 1000000
    if (d <= 0) d = 0
    printf "%.4f|%d:%02d|%d:%02d|%s", (d > 0 ? p / d : 0), int(p / 60), int(p) % 60, int(d / 60), int(d) % 60, m
}'
