#!/bin/sh
# Change volume and show a replaceable desktop notification.
# Usage: volume-osd.sh up|down|mute

case "$1" in
  up)   wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
  down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
  mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  *)    echo "usage: $0 up|down|mute" >&2; exit 1 ;;
esac

status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)   # "Volume: 0.55 [MUTED]"
vol=$(echo "$status" | awk '{print int($2 * 100 + 0.5)}')

if echo "$status" | grep -q MUTED; then
  notify-send -a volume -r 9912 -u low -h int:value:0 -t 2500 "Muted"
else
  notify-send -a volume -r 9912 -u low -h int:value:"$vol" -t 2500 "Volume ${vol}%"
fi
