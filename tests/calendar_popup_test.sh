#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d)
harness="$test_dir/shell.qml"

cp "$repo_root/dot_config/quickshell/CalendarPopup.qml" "$test_dir/CalendarPopup.qml"
cp "$repo_root/tests/calendar_popup_harness.qml" "$harness"

cleanup() {
    quickshell kill -p "$harness" >/dev/null 2>&1 || true
    rm -rf "$test_dir"
}
trap cleanup EXIT INT TERM

quickshell -d -p "$harness"

attempt=0
while [ "$attempt" -lt 50 ]; do
    if result=$(quickshell ipc -p "$harness" call calendarPopupTest run 2>/dev/null); then
        [ "$result" = "true" ]
        printf '%s\n' 'ok - calendar starts weeks on Sunday and preserves ISO week labels'
        exit 0
    fi

    attempt=$((attempt + 1))
    sleep 0.1
done

printf '%s\n' 'calendar popup test harness did not become ready' >&2
exit 1
