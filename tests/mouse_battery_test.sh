#!/usr/bin/env sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT HUP INT TERM

mkdir -p "$temp_dir/bin" "$temp_dir/home/.cache"

cat >"$temp_dir/bin/mow" <<'EOF'
#!/usr/bin/env sh

if [ "$*" != 'report battery' ]; then
    printf 'Unexpected mow command: %s\n' "$*" >&2
    exit 64
fi

printf '%s\n' "$FAKE_MOUSE_BATTERY"
EOF

cat >"$temp_dir/bin/notify-send" <<'EOF'
#!/usr/bin/env sh

printf '<%s>' "$@" >>"$FAKE_NOTIFY_CALLS"
printf '\n' >>"$FAKE_NOTIFY_CALLS"
EOF

chmod +x "$temp_dir/bin/mow" "$temp_dir/bin/notify-send"
export FAKE_NOTIFY_CALLS="$temp_dir/notify-calls"

run_battery() {
    battery=$1
    output=$(FAKE_MOUSE_BATTERY="$battery" HOME="$temp_dir/home" PATH="$temp_dir/bin:$PATH" \
        sh "$repo_root/scripts/executable_mouse-battery.sh")

    if [ "$output" != "󰍽 $battery" ]; then
        printf 'Unexpected bar output for %s: %s\n' "$battery" "$output" >&2
        exit 1
    fi
}

run_battery '49%'
run_battery '30%'
run_battery '30%'
run_battery '20%'
run_battery '20%'
run_battery '10%'
run_battery '10%'
run_battery '5%'
run_battery '5%'
run_battery '49%'
run_battery '30%'
run_battery '30%'
run_battery '21%'
run_battery '19%'
run_battery '19%'

expected_calls="<-a><mouse-battery><-i><$temp_dir/home/.local/share/icons/mouse-battery.svg><-u><normal><Mouse battery low><30% remaining>
<-a><mouse-battery><-i><$temp_dir/home/.local/share/icons/mouse-battery.svg><-u><normal><Mouse battery low><20% remaining>
<-a><mouse-battery><-i><$temp_dir/home/.local/share/icons/mouse-battery.svg><-u><critical><Mouse battery low><10% remaining>
<-a><mouse-battery><-i><$temp_dir/home/.local/share/icons/mouse-battery.svg><-u><critical><Mouse battery low><5% remaining>
<-a><mouse-battery><-i><$temp_dir/home/.local/share/icons/mouse-battery.svg><-u><normal><Mouse battery low><30% remaining>
<-a><mouse-battery><-i><$temp_dir/home/.local/share/icons/mouse-battery.svg><-u><normal><Mouse battery low><19% remaining>"
actual_calls=$(cat "$FAKE_NOTIFY_CALLS")

if [ "$actual_calls" != "$expected_calls" ]; then
    printf 'Unexpected battery notifications:\n%s\n' "$actual_calls" >&2
    exit 1
fi

printf 'ok - mouse battery thresholds notify once per charge cycle\n'
