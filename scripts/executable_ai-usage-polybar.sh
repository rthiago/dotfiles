#!/bin/sh
# Polybar wrapper for claude-usage / codex-usage.
#
# Both binaries only emit Waybar JSON (--waybar); their --format flag is a no-op
# without it. This pulls the JSON apart for polybar:
#   (no mode)  one bar line: the icon (brand-colored by the binary, red on
#              error) plus percent + reset, with the whole widget underlined in
#              that same color. Pango <span> markup is rewritten to polybar
#              %{F}/%{u} tags, since polybar can't render Pango.
#   popup      the .tooltip breakdown (5h / 7d windows) as a dunst notification,
#              bound to click-left in the bar (polybar has no hover tooltips).
#
# Usage: ai-usage-polybar.sh {claude|codex} [popup]

tool="$1"
mode="$2"
bin="${tool}-usage"
command -v "$bin" >/dev/null 2>&1 || exit 0

# claude-usage authenticates by scraping claude.ai browser cookies. Its default
# browser order tries Chrome first and returns the first browser holding any
# claude.ai cookie, so a stale Chrome session 403s ("Auth Err") before Brave is
# ever tried. Pin it to Brave, the logged-in default browser. codex-usage needs
# no browser: it reads its own token at ~/.codex/auth.json.
case "$tool" in
    claude) set -- --browser brave ;;
    *)      set -- ;;
esac

json=$("$bin" "$@" --waybar --format '{icon} {pct}% {reset}' 2>/dev/null)
[ -n "$json" ] || exit 0

if [ "$mode" = popup ]; then
    # Drop the "Click to Refresh" footer (a waybar instruction; in polybar the
    # click is what opened this popup) and any blank lines, then escape for
    # dunst's pango markup and render <tt> so the table columns line up.
    tip=$(printf '%s' "$json" | jq -r '.tooltip // empty' \
        | grep -iv '^[[:space:]]*click to refresh[[:space:]]*$' \
        | grep -v '^[[:space:]]*$' \
        | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')
    [ -n "$tip" ] || exit 0
    title=$(printf '%s' "$tool" | sed 's/^./\u&/')
    dunstify -a ai-usage -r 9911 -u normal "$title usage" "<tt>$tip</tt>"
    exit 0
fi

text=$(printf '%s' "$json" | jq -r '.text // empty')
[ -n "$text" ] || exit 0

# The binary colors only the icon (or, on error, the whole string) with a Pango
# <span foreground='#hex'>. Pull that hex out and paint the entire widget with
# it -- icon, text and underline -- so each widget is one flat brand color like
# every other module on the bar (and goes fully red on error). Then strip Pango,
# which polybar can't render.
color=$(printf '%s' "$text" | grep -oE '#[0-9A-Fa-f]{3,8}' | head -1)
plain=$(printf '%s' "$text" | sed -E 's/<[^>]*>//g')
if [ -n "$color" ]; then
    printf '%%{u%s}%%{+u}%%{F%s}%s%%{F-}%%{-u}\n' "$color" "$color" "$plain"
else
    printf '%s\n' "$plain"
fi
