#!/usr/bin/env sh

quickshell kill >/dev/null 2>&1 || true
killall -q polybar

while pgrep -x polybar >/dev/null; do sleep 1; done

# Full bar (with tray) on the primary output; a stripped bar on the rest.
primary=$(polybar --list-monitors | grep -m1 '(primary)' | cut -d: -f1)
[ -z "$primary" ] && primary=$(polybar --list-monitors | head -1 | cut -d: -f1)

for m in $(polybar --list-monitors | cut -d: -f1); do
    if [ "$m" = "$primary" ]; then
        MONITOR=$m polybar --reload main &
    else
        MONITOR=$m polybar --reload secondary &
    fi
done
