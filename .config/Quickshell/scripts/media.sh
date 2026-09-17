#!/bin/sh
# Output: <progress 0..1>|<position>|<duration>|<status>~<artist>~<title>~<album>~<artUrl>~<player>
#
# <player> is the MPRIS name of whatever is playing, e.g. "spotify",
# "firefox.instance_1_2" or "mpv". The UI strips the instance suffix.
pos=$(playerctl position 2>/dev/null || printf 0)
len=$(playerctl metadata --format '{{mpris:length}}' 2>/dev/null || printf 0)
meta=$(playerctl metadata --format '{{status}}~{{artist}}~{{title}}~{{album}}~{{mpris:artUrl}}~{{playerName}}' 2>/dev/null)
[ -n "$meta" ] || meta="Stopped~~~~~"

awk -v p="$pos" -v l="$len" -v m="$meta" 'BEGIN {
    d = l / 1000000
    if (d <= 0) d = 0
    printf "%.4f|%d:%02d|%d:%02d|%s", (d > 0 ? p / d : 0), int(p / 60), int(p) % 60, int(d / 60), int(d) % 60, m
}'
