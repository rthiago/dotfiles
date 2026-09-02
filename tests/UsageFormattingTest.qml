import QtQuick 2.15
import "../dot_config/quickshell/UsageFormatting.js" as UsageFormatting

Item {
    id: root
    visible: false
    function expectCountdown(metric, now, expected, scenario) {
        const actual = UsageFormatting.resetCountdown(metric, now)
        if (actual === expected) return true

        console.error("FAIL - " + scenario + ": expected '" + expected + "', got '" + actual + "'")
        Qt.exit(1)
        return false
    }

    function runTests() {
        const now = Date.parse("2026-09-02T17:00:00Z")
        if (!expectCountdown({
            detail: "Resets in 2h 15m · 50% elapsed",
            reset_at: "2026-09-02T22:00:00Z"
        }, now, "2h 15m", "provider detail takes precedence")) return
        if (!expectCountdown({
            detail: "",
            reset_at: "2026-09-02T22:00:00Z"
        }, now, "5h 0m", "empty detail falls back to reset timestamp")) return
        if (!expectCountdown({
            reset_at: "2026-09-04T20:30:00Z"
        }, now, "2d 3h", "multi-day countdown matches existing format")) return
        if (!expectCountdown({ reset_at: "invalid" }, now, "", "invalid timestamp is omitted")) return
        if (!expectCountdown({
            reset_at: "2026-09-02T16:00:00Z"
        }, now, "", "expired timestamp is omitted")) return

        console.log("ok - usage reset countdown formatting")
        Qt.exit(0)
    }

    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: root.runTests()
    }
}
