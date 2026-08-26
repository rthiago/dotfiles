#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d)
harness="$test_dir/shell.qml"

cp "$repo_root/dot_config/quickshell/NotificationCard.qml" "$test_dir/NotificationCard.qml"
cp "$repo_root/tests/notification_card_harness.qml" "$harness"

cleanup() {
    quickshell kill -p "$harness" >/dev/null 2>&1 || true
    rm -rf "$test_dir"
}
trap cleanup EXIT INT TERM

quickshell -d -p "$harness"

attempt=0
while [ "$attempt" -lt 50 ]; do
    if result=$(quickshell ipc -p "$harness" call notificationCardTest run 2>/dev/null); then
        [ "$result" = "true" ]
        printf '%s\n' 'ok - notification card hides empty actions and uses a fallback monogram'
        exit 0
    fi

    attempt=$((attempt + 1))
    sleep 0.1
done

printf '%s\n' 'notification card test harness did not become ready' >&2
exit 1
