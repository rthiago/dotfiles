#!/bin/sh
# Change volume and show a dunst notification with a progress bar slider.
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
  dunstify -a volume -u low -h string:x-dunst-stack-tag:volume -t 1500 "Muted"
else
  dunstify -a volume -u low -h string:x-dunst-stack-tag:volume \
    -h int:value:"$vol" -t 1500 "Volume ${vol}%"
fi
