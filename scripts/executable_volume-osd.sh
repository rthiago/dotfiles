#!/bin/sh
# Change volume and update the Quickshell OSD.
# Usage: volume-osd.sh up|down|mute

case "$1" in
  up)   wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
  down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
  mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
  *)    echo "usage: $0 up|down|mute" >&2; exit 1 ;;
esac

quickshell ipc call volumeOsd display >/dev/null 2>&1 || true
