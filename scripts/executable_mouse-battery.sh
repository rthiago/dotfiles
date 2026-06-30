#!/bin/sh
val=$(mow report battery 2>/dev/null)
cache="$HOME/.cache/mouse-battery"
if [ -n "$val" ]; then printf '%s' "$val" > "$cache" 2>/dev/null; else val=$(cat "$cache" 2>/dev/null); fi
echo -n "󰍽 ${val}"
