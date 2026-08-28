import QtQuick
import Quickshell
import Quickshell.Io
import "."

ShellRoot {
    id: root

    QtObject {
        id: theme

        readonly property color muted: "#a6adc8"
        readonly property color purple: "#cba6f7"
        readonly property color panel: "#2a2b3c"
        readonly property color highlight: "#45475a"
        readonly property color foreground: "#cdd6f4"
        readonly property string fontFamily: "sans-serif"
        readonly property string monoFontFamily: "monospace"
        readonly property string iconFontFamily: "sans-serif"
        readonly property int fontSizeCaption: 11
        readonly property int fontSizeLabel: 11
        readonly property int fontSizeSmall: 12
        readonly property int fontSizeBody: 13
        readonly property int fontSizeIcon: 17
        readonly property int fontSizeTitle: 18
    }

    PanelWindow {
        id: hostWindow
        visible: false
        implicitWidth: 1920
        implicitHeight: 32
    }

    CalendarPopup {
        id: calendar
        hostWindow: hostWindow
        theme: theme
    }

    IpcHandler {
        target: "calendarPopupTest"

        function run(): bool {
            calendar.viewYear = 2024
            calendar.viewMonth = 0
            calendar.rebuild()

            const firstWeek = calendar.weeks[0]
            return calendar.weekdayLabels.join(",") === "SUN,MON,TUE,WED,THU,FRI,SAT"
                && firstWeek.week === 1
                && firstWeek.days[0].day === 31
                && !firstWeek.days[0].inMonth
                && firstWeek.days[0].weekend
                && firstWeek.days[1].day === 1
                && firstWeek.days[1].inMonth
                && !firstWeek.days[1].weekend
                && firstWeek.days[6].day === 6
                && firstWeek.days[6].weekend
        }
    }
}
