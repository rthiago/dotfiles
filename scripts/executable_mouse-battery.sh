#!/bin/sh

battery_cache="$HOME/.cache/mouse-battery"
notification_cache="$HOME/.cache/mouse-battery-notified"
notification_icon="$HOME/.local/share/icons/mouse-battery.svg"
previous=$(cat "$battery_cache" 2>/dev/null)
val=$(mow report battery 2>/dev/null)

if [ -n "$val" ]; then
    printf '%s' "$val" >"$battery_cache" 2>/dev/null
else
    val=$previous
fi

battery=${val%\%}
previous_battery=${previous%\%}
case "$battery" in ''|*[!0-9]*) battery= ;; esac
case "$previous_battery" in ''|*[!0-9]*) previous_battery= ;; esac

if [ -n "$battery" ] && [ "$battery" -gt 30 ] && [ -s "$notification_cache" ]; then
    : >"$notification_cache"
fi

notified=$(cat "$notification_cache" 2>/dev/null)
if [ -n "$battery" ]; then
    for threshold in 30 20 10 5; do
        if [ -n "$previous_battery" ]; then
            [ "$previous_battery" -gt "$threshold" ] && [ "$battery" -le "$threshold" ] || continue
        else
            [ "$battery" -eq "$threshold" ] || continue
        fi

        case "
$notified
" in
            *"
$threshold
"*) continue ;;
        esac

        case "$threshold" in
            30|20) urgency=normal ;;
            10|5) urgency=critical ;;
        esac
        if notify-send -a mouse-battery -i "$notification_icon" -u "$urgency" 'Mouse battery low' "$val remaining"; then
            printf '%s\n' "$threshold" >>"$notification_cache"
        fi
    done
fi

printf '󰍽 %s' "$val"
