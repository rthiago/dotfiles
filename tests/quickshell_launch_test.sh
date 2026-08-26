#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
temp_dir=$(mktemp -d)
old_pid=""

cleanup() {
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
        kill "$old_pid" 2>/dev/null || true
        wait "$old_pid" 2>/dev/null || true
    fi
    rm -rf "$temp_dir"
}
trap cleanup EXIT HUP INT TERM

mkdir -p "$temp_dir/bin"

cat >"$temp_dir/bin/quickshell" <<'EOF'
#!/usr/bin/env sh

case "${1-}" in
    list)
        if kill -0 "$FAKE_QS_OLD_PID" 2>/dev/null; then
            printf 'Instance test:\n  Process ID: %s\n' "$FAKE_QS_OLD_PID"
        fi
        ;;
    kill)
        : >"$FAKE_QS_STOP_FILE"
        ;;
    --no-duplicate)
        if kill -0 "$FAKE_QS_OLD_PID" 2>/dev/null; then
            printf 'An instance of this configuration is already running.\n' >&2
            exit 1
        fi
        : >"$FAKE_QS_LAUNCHED_FILE"
        ;;
    *)
        printf 'Unexpected quickshell command: %s\n' "${1-}" >&2
        exit 64
        ;;
esac
EOF

cat >"$temp_dir/bin/xrandr" <<'EOF'
#!/usr/bin/env sh
printf 'DP-0 connected primary 1920x1080+0+0\n'
EOF

cat >"$temp_dir/bin/killall" <<'EOF'
#!/usr/bin/env sh
exit 0
EOF

chmod +x "$temp_dir/bin/quickshell" "$temp_dir/bin/xrandr" "$temp_dir/bin/killall"

export FAKE_QS_STOP_FILE="$temp_dir/stop"
export FAKE_QS_LAUNCHED_FILE="$temp_dir/launched"

(
    while [ ! -e "$FAKE_QS_STOP_FILE" ]; do
        sleep 0.01
    done
    sleep 0.2
) &
old_pid=$!
export FAKE_QS_OLD_PID="$old_pid"

PATH="$temp_dir/bin:$PATH" sh "$repo_root/dot_config/quickshell/executable_launch.sh"
wait "$old_pid"
old_pid=""

if [ ! -e "$FAKE_QS_LAUNCHED_FILE" ]; then
    printf 'Launcher did not start Quickshell after shutdown.\n' >&2
    exit 1
fi

printf 'ok - launcher waits for prior Quickshell instance\n'
