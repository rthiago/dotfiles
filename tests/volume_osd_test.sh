#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM

mkdir -p "$temp_dir/bin"

cat >"$temp_dir/bin/wpctl" <<'EOF'
#!/usr/bin/env sh

case "${1-}" in
    set-volume|set-mute)
        printf '%s\n' "$*" >>"$FAKE_WPCTL_ACTIONS"
        ;;
    *)
        printf 'Unexpected wpctl command: %s\n' "${1-}" >&2
        exit 64
        ;;
esac
EOF

cat >"$temp_dir/bin/quickshell" <<'EOF'
#!/usr/bin/env sh
printf '%s\n' "$*" >>"$FAKE_QUICKSHELL_CALLS"
EOF

cat >"$temp_dir/bin/notify-send" <<'EOF'
#!/usr/bin/env sh
: >"$FAKE_NOTIFY_CALLED"
exit 99
EOF

chmod +x "$temp_dir/bin/wpctl" "$temp_dir/bin/quickshell" "$temp_dir/bin/notify-send"

export FAKE_WPCTL_ACTIONS="$temp_dir/wpctl-actions"
export FAKE_QUICKSHELL_CALLS="$temp_dir/quickshell-calls"
export FAKE_NOTIFY_CALLED="$temp_dir/notify-called"

PATH="$temp_dir/bin:$PATH" sh "$repo_root/scripts/executable_volume-osd.sh" up

PATH="$temp_dir/bin:$PATH" sh "$repo_root/scripts/executable_volume-osd.sh" down

PATH="$temp_dir/bin:$PATH" sh "$repo_root/scripts/executable_volume-osd.sh" mute

expected_actions='set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
set-volume @DEFAULT_AUDIO_SINK@ 5%-
set-mute @DEFAULT_AUDIO_SINK@ toggle'
actual_actions=$(cat "$FAKE_WPCTL_ACTIONS")

if [ "$actual_actions" != "$expected_actions" ]; then
    printf 'Unexpected wpctl actions:\n%s\n' "$actual_actions" >&2
    exit 1
fi

expected_calls='ipc call volumeOsd display
ipc call volumeOsd display
ipc call volumeOsd display'
actual_calls=$(cat "$FAKE_QUICKSHELL_CALLS")

if [ "$actual_calls" != "$expected_calls" ]; then
    printf 'Unexpected Quickshell IPC calls:\n%s\n' "$actual_calls" >&2
    exit 1
fi

if [ -e "$FAKE_NOTIFY_CALLED" ]; then
    printf 'Volume control invoked notify-send.\n' >&2
    exit 1
fi

printf 'ok - volume changes update one Quickshell OSD\n'
