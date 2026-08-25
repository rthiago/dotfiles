#!/usr/bin/env sh

# Stop only bar processes. The Polybar configuration remains intact as the
# rollback path while Quickshell is being evaluated.
quickshell kill >/dev/null 2>&1 || true
killall -q polybar 2>/dev/null || true

primary_monitor=$(xrandr --query | awk '$2 == "connected" && $3 == "primary" { print $1; exit }')
if [ -z "$primary_monitor" ]; then
    primary_monitor=$(xrandr --query | awk '$2 == "connected" { print $1; exit }')
fi

cpu_temperature_path=""
for name_path in /sys/class/hwmon/hwmon*/name; do
    [ -r "$name_path" ] || continue
    [ "$(cat "$name_path")" = "k10temp" ] || continue
    candidate="${name_path%/name}/temp1_input"
    if [ -r "$candidate" ]; then
        cpu_temperature_path="$candidate"
        break
    fi
done

export QS_PRIMARY_MONITOR="$primary_monitor"
export QS_CPU_TEMP_PATH="$cpu_temperature_path"

exec quickshell --no-duplicate --daemonize
