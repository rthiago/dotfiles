#!/bin/sh
# Polybar wrapper for ai-usagebar (github.com/akitaonrails/ai-usagebar).
#
# ai-usagebar only emits Waybar JSON ({text, tooltip, class}); this pulls the
# JSON apart for polybar:
#   (no mode)  one bar line: brand icon + percent + reset, with the whole
#              widget underlined and tinted in the widget's flat brand color
#              (red on error). Pango <span> markup is rewritten to polybar
#              %{F}/%{u} tags, since polybar can't render Pango.
#   popup      the .tooltip breakdown (session / weekly windows) as a desktop
#              notification, bound to click-left in the bar (polybar has no
#              hover tooltips). Markup is stripped so every freedesktop
#              notification server renders the box-drawing frame correctly.
#
# Usage: ai-usage-polybar.sh {claude|codex} [popup]

tool="$1"
mode="$2"
command -v ai-usagebar >/dev/null 2>&1 || exit 0

# Auth comes from the CLIs' own credential files (~/.claude/.credentials.json,
# ~/.codex/auth.json) -- if a widget shows an auth error, log the CLI back in.
case "$tool" in
    claude) brand='#DE7356'; set -- --vendor anthropic --icon "󰜡" ;;
    codex)  brand='#74AA9C'; set -- --vendor openai --icon "󰬫" ;;
    *)      exit 0 ;;
esac

json=$(ai-usagebar "$@" --json 2>/dev/null)
[ -n "$json" ] || exit 0

if [ "$mode" = popup ]; then
    tip=$(printf '%s' "$json" | jq -r '.tooltip // empty' | sed -E 's/<[^>]*>//g')
    [ -n "$tip" ] || exit 0
    title=$(printf '%s' "$tool" | sed 's/^./\u&/')
    notify-send -a ai-usage -r 9911 -u normal "$title usage" "$tip"
    exit 0
fi

text=$(printf '%s' "$json" | jq -r '.text // empty')
[ -n "$text" ] || exit 0

# The binary colors the line by usage level; the bar instead keeps one flat
# brand color per widget, like every other module. The binary's Pango <span>
# is only an error probe: on failure the text is a bare "⚠" with no span, and
# the whole widget goes red. Strip the Pango markup, which polybar can't
# render, then paint icon, text and underline alike.
if printf '%s' "$text" | grep -q '<span'; then
    color=$brand
else
    color='#ff5555'
fi
plain=$(printf '%s' "$text" | sed -E 's/<[^>]*>//g')
printf '%%{u%s}%%{+u}%%{F%s}%s%%{F-}%%{-u}\n' "$color" "$color" "$plain"
