import QtQuick
import Quickshell

PopupWindow {
    id: root

    required property var hostWindow
    required property var theme
    property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()
    property var weeks: []

    readonly property date viewDate: new Date(viewYear, viewMonth, 1)
    readonly property int yearPercent: {
        const start = new Date(today.getFullYear(), 0, 1)
        const end = new Date(today.getFullYear() + 1, 0, 1)
        return Math.floor(100 * (today.getTime() - start.getTime()) / (end.getTime() - start.getTime()))
    }

    anchor.window: hostWindow
    anchor.adjustment: PopupAdjustment.Slide
    anchor.rect.x: Math.round(hostWindow.width / 2 - width / 2)
    anchor.rect.y: hostWindow.height + 8
    implicitWidth: 546
    implicitHeight: 440
    color: "transparent"
    grabFocus: true
    visible: false

    function isoWeek(date) {
        const target = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()))
        const day = target.getUTCDay() || 7
        target.setUTCDate(target.getUTCDate() + 4 - day)
        const yearStart = new Date(Date.UTC(target.getUTCFullYear(), 0, 1))
        return Math.ceil((((target - yearStart) / 86400000) + 1) / 7)
    }

    function sameDay(left, right) {
        return left.getFullYear() === right.getFullYear()
            && left.getMonth() === right.getMonth()
            && left.getDate() === right.getDate()
    }

    function rebuild() {
        const first = new Date(viewYear, viewMonth, 1)
        const mondayOffset = (first.getDay() + 6) % 7
        const start = new Date(viewYear, viewMonth, 1 - mondayOffset)
        const result = []

        for (let row = 0; row < 6; row++) {
            const monday = new Date(start.getFullYear(), start.getMonth(), start.getDate() + row * 7)
            const days = []
            for (let column = 0; column < 7; column++) {
                const date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + column)
                days.push({
                    day: date.getDate(),
                    inMonth: date.getMonth() === viewMonth,
                    today: sameDay(date, today),
                    weekend: date.getDay() === 0 || date.getDay() === 6
                })
            }
            result.push({ week: isoWeek(monday), days: days })
        }

        weeks = result
    }

    function moveMonth(delta) {
        const next = new Date(viewYear, viewMonth + delta, 1)
        viewYear = next.getFullYear()
        viewMonth = next.getMonth()
    }

    function goToToday() {
        today = new Date()
        viewYear = today.getFullYear()
        viewMonth = today.getMonth()
    }

    onViewYearChanged: rebuild()
    onViewMonthChanged: rebuild()
    onTodayChanged: rebuild()
    onVisibleChanged: {
        if (visible) {
            goToToday()
            keyScope.forceActiveFocus()
        }
    }
    Component.onCompleted: rebuild()

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.today = new Date()
    }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: root.theme.panel
        border.width: 1
        border.color: Qt.rgba(root.theme.purple.r, root.theme.purple.g, root.theme.purple.b, 0.5)

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            Item {
                width: parent.width
                height: 44

                Rectangle {
                    id: calendarIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 34
                    height: 34
                    radius: 10
                    color: Qt.rgba(root.theme.purple.r, root.theme.purple.g, root.theme.purple.b, 0.16)

                    Text {
                        anchors.centerIn: parent
                        text: "󰃭"
                        color: root.theme.purple
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.fontSizeIcon
                        renderType: Text.NativeRendering
                    }
                }

                Column {
                    anchors.left: calendarIcon.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3

                    Text {
                        width: parent.width
                        text: "Calendar"
                        color: root.theme.foreground
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeTitle
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        renderType: Text.NativeRendering
                    }

                    Text {
                        width: parent.width
                        text: Qt.formatDate(root.today, "dddd, MMMM d")
                        color: root.theme.muted
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeSmall
                        elide: Text.ElideRight
                        renderType: Text.NativeRendering
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.7)
            }

            Item {
                width: parent.width
                height: 20

                Text {
                    id: yearLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.today.getFullYear()
                    color: root.theme.muted
                    font.family: root.theme.monoFontFamily
                    font.pixelSize: root.theme.fontSizeCaption
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering
                }

                Text {
                    id: yearPercentLabel
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.yearPercent + "%"
                    color: root.theme.foreground
                    font.family: root.theme.monoFontFamily
                    font.pixelSize: root.theme.fontSizeCaption
                    renderType: Text.NativeRendering
                }

                Rectangle {
                    anchors.left: yearLabel.right
                    anchors.right: yearPercentLabel.left
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    height: 6
                    radius: 3
                    color: Qt.rgba(root.theme.foreground.r, root.theme.foreground.g, root.theme.foreground.b, 0.12)

                    Rectangle {
                        width: parent.width * root.yearPercent / 100
                        height: parent.height
                        radius: parent.radius
                        color: root.theme.purple

                        Behavior on width {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }

            Row {
                width: parent.width
                height: 18
                spacing: 4

                Text {
                    width: 34
                    height: parent.height
                    text: "W"
                    color: root.theme.muted
                    opacity: 0.65
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeLabel
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }

                Repeater {
                    model: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

                    Text {
                        required property string modelData
                        width: 64
                        height: 18
                        text: modelData
                        color: root.theme.muted
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: root.theme.fontFamily
                        font.pixelSize: root.theme.fontSizeLabel
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                        renderType: Text.NativeRendering
                    }
                }
            }

            Item {
                width: parent.width
                height: 225

                WheelHandler {
                    onWheel: event => {
                        if (event.angleDelta.y !== 0)
                            root.moveMonth(event.angleDelta.y > 0 ? -1 : 1)
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 3

                    Repeater {
                        model: root.weeks

                        Row {
                            required property var modelData
                            spacing: 4

                            Text {
                                width: 34
                                height: 35
                                text: parent.modelData.week
                                color: root.theme.muted
                                opacity: 0.55
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.family: root.theme.fontFamily
                                font.pixelSize: root.theme.fontSizeLabel
                                renderType: Text.NativeRendering
                            }

                            Repeater {
                                model: parent.modelData.days

                                Rectangle {
                                    required property var modelData
                                    width: 64
                                    height: 35
                                    radius: 8
                                    color: modelData.today
                                        ? Qt.rgba(root.theme.purple.r, root.theme.purple.g, root.theme.purple.b, 0.14)
                                        : "transparent"
                                    border.width: modelData.today ? 1 : 0
                                    border.color: root.theme.purple

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.modelData.day
                                        color: !parent.modelData.inMonth
                                            ? Qt.rgba(root.theme.muted.r, root.theme.muted.g, root.theme.muted.b, 0.45)
                                            : parent.modelData.weekend
                                                ? root.theme.muted
                                                : root.theme.foreground
                                        font.family: root.theme.fontFamily
                                        font.pixelSize: root.theme.fontSizeBody
                                        font.bold: parent.modelData.today
                                        renderType: Text.NativeRendering
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 36

                Rectangle {
                    id: previousButton
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 30
                    radius: 8
                    color: previousPointer.containsMouse ? root.theme.highlight : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅁"
                        color: root.theme.foreground
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.fontSizeTitle
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: previousPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.moveMonth(-1)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDate(root.viewDate, "MMMM yyyy").toUpperCase()
                    color: root.theme.muted
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSizeBody
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goToToday()
                    }
                }

                Rectangle {
                    id: nextButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    height: 30
                    radius: 8
                    color: nextPointer.containsMouse ? root.theme.highlight : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰅂"
                        color: root.theme.foreground
                        font.family: root.theme.iconFontFamily
                        font.pixelSize: root.theme.fontSizeTitle
                        renderType: Text.NativeRendering
                    }

                    MouseArea {
                        id: nextPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.moveMonth(1)
                    }
                }
            }
        }
    }

    FocusScope {
        id: keyScope
        anchors.fill: parent
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) root.visible = false
            else if (event.key === Qt.Key_Left) root.moveMonth(-1)
            else if (event.key === Qt.Key_Right) root.moveMonth(1)
            else if (event.key === Qt.Key_Up) root.moveMonth(-12)
            else if (event.key === Qt.Key_Down) root.moveMonth(12)
            else if (event.key === Qt.Key_Home) root.goToToday()
            else return
            event.accepted = true
        }
    }
}
