import QtQuick
import Quickshell
import Quickshell.I3
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.SystemTray

PanelWindow {
    id: root

    required property var modelData
    required property var services
    required property var theme

    readonly property bool isPrimary: modelData.name === services.primaryScreenName
    readonly property int barHeight: 42
    property string utcClockText: "UTC --:--"
    property string centralEuropeanClockText: "CET --:--"

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: barHeight
    exclusiveZone: barHeight
    color: "transparent"

    Rectangle {
        id: background
        anchors.fill: parent
        color: root.theme.barBackground

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.65)
        }
    }

    Item {
        id: barContent
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        Row {
            id: leftGroup
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            Row {
                id: workspaceRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Repeater {
                    model: I3.workspaces

                    Rectangle {
                        id: workspace
                        required property var modelData

                        readonly property bool onThisMonitor: modelData.monitor && modelData.monitor.name === root.modelData.name

                        visible: onThisMonitor
                        width: modelData.active ? 34 : 27
                        height: 28
                        radius: 9
                        color: modelData.urgent
                            ? root.theme.red
                            : modelData.active
                                ? root.theme.purple
                                : workspacePointer.containsMouse
                                    ? root.theme.highlight
                                    : Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.28)

                        Behavior on width {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: workspace.modelData.number
                            color: workspace.modelData.active || workspace.modelData.urgent
                                ? root.theme.background
                                : root.theme.foreground
                            font.family: root.theme.fontFamily
                            font.pixelSize: root.theme.fontSizeTitle
                            font.bold: workspace.modelData.active
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            id: workspacePointer
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: I3.dispatch("workspace number " + workspace.modelData.number)
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: root.theme.highlight
            }

            Text {
                width: Math.min(root.isPrimary ? 980 : 720, root.width * 0.44)
                anchors.verticalCenter: parent.verticalCenter
                text: root.services.windowTitle || "Desktop"
                color: root.theme.muted
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSizeTitle
                elide: Text.ElideRight
                renderType: Text.NativeRendering
            }
        }

        BarChip {
            id: clockChip
            visible: root.isPrimary
            anchors.centerIn: parent
            theme: root.theme
            text: Qt.formatDateTime(clock.date, "ddd  d MMM yyyy  •  HH:mm")
            accent: root.theme.purple
            selected: calendarPopup.visible
            onClicked: {
                infoPopup.visible = false
                networkPopup.visible = false
                calendarPopup.visible = !calendarPopup.visible
            }
        }

        Row {
            visible: !root.isPrimary
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            BarChip {
                theme: root.theme
                text: root.centralEuropeanClockText
                accent: root.theme.orange
            }

            BarChip {
                theme: root.theme
                text: root.utcClockText
                accent: root.theme.cyan
            }
        }

        Row {
            id: rightGroup
            visible: root.isPrimary
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            BarChip {
                id: claudeChip
                theme: root.theme
                text: root.services.claudeText
                accent: root.services.claudeError ? root.theme.red : root.theme.orange
                selected: infoPopup.visible && infoPopup.providerId === "anthropic"
                onClicked: root.openInfo(claudeChip, "anthropic", root.services.claudeUsage, accent)
            }

            BarChip {
                id: codexChip
                theme: root.theme
                text: root.services.codexText
                accent: root.services.codexError ? root.theme.red : root.theme.green
                selected: infoPopup.visible && infoPopup.providerId === "openai"
                onClicked: root.openInfo(codexChip, "openai", root.services.codexUsage, accent)
            }

            BarChip {
                id: opencodeGoChip
                theme: root.theme
                text: root.services.opencodeGoText
                accent: root.services.opencodeGoError ? root.theme.red : root.theme.cyan
                selected: infoPopup.visible && infoPopup.providerId === "opencode-go"
                onClicked: root.openInfo(opencodeGoChip, "opencode-go", root.services.opencodeGoUsage, accent)
            }

            BarChip {
                id: openRouterChip
                theme: root.theme
                text: root.services.openRouterText
                accent: root.services.openRouterError ? root.theme.red : root.theme.purple
                selected: infoPopup.visible && infoPopup.providerId === "openrouter"
                onClicked: root.openInfo(openRouterChip, "openrouter", root.services.openRouterUsage, accent)
            }

            BarChip {
                theme: root.theme
                text: root.services.bitcoinText
                accent: root.theme.yellow
            }

            BarChip {
                theme: root.theme
                text: root.services.headphonesText
                accent: root.theme.purple
            }

            BarChip {
                theme: root.theme
                text: root.services.mouseText
                accent: root.theme.green
            }

            BarChip {
                theme: root.theme
                text: root.services.keyboardText
                accent: root.theme.cyan
            }

            BarChip {
                id: audioChip
                theme: root.theme
                text: root.services.audioText
                accent: root.services.audioMuted ? root.theme.red : root.theme.pink
                onClicked: button => {
                    if (button === Qt.RightButton)
                        Quickshell.execDetached({ command: ["pavucontrol"] })
                    else if (button === Qt.LeftButton)
                        root.services.toggleAudioMute()
                }
                onWheel: delta => root.services.adjustAudioVolume(delta > 0 ? 0.03 : -0.03)
            }

            BarChip {
                theme: root.theme
                text: " " + root.services.cpuPercent + "%"
                accent: root.theme.orange
            }

            BarChip {
                theme: root.theme
                text: "󰍛 " + root.services.memoryPercent + "%"
                accent: root.theme.purple
            }

            BarChip {
                theme: root.theme
                text: " " + root.services.temperatureText
                accent: root.services.temperatureWarning ? root.theme.red : root.theme.yellow
            }

            Rectangle {
                visible: SystemTray.items.values.length > 0
                width: visible ? 1 : 0
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: root.theme.highlight
            }

            BarChip {
                id: networkChip
                theme: root.theme
                compact: true
                text: root.services.networkIcon || "󰖪"
                accent: root.services.wireguardConnected
                    ? root.theme.yellow
                    : root.services.networkConnected
                        ? root.theme.green
                        : root.theme.red
                selected: networkPopup.visible
                onClicked: button => {
                    if (button === Qt.LeftButton || button === Qt.RightButton) {
                        calendarPopup.visible = false
                        infoPopup.visible = false
                        networkPopup.toggleFor(networkChip)
                    }
                }
            }

            Repeater {
                model: SystemTray.items

                Rectangle {
                    id: trayItem
                    required property var modelData
                    width: 28
                    height: 28
                    radius: 9
                    color: trayPointer.containsMouse
                        ? root.theme.highlight
                        : Qt.rgba(root.theme.highlight.r, root.theme.highlight.g, root.theme.highlight.b, 0.24)

                    IconImage {
                        anchors.centerIn: parent
                        width: 18
                        height: 18
                        source: trayItem.modelData.icon
                    }

                    MouseArea {
                        id: trayPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                                const point = trayItem.mapToItem(barContent, 0, 0)
                                trayItem.modelData.display(root, Math.round(point.x), root.height)
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayItem.modelData.secondaryActivate()
                            } else {
                                trayItem.modelData.activate()
                            }
                        }
                    }
                }
            }
        }
    }

    function openInfo(item, providerId, usage, accent) {
        calendarPopup.visible = false
        networkPopup.visible = false
        infoPopup.toggleFor(item, providerId, usage, accent)
    }

    function refreshWorldClocks() {
        if (root.isPrimary)
            return

        utcClock.running = true
        centralEuropeanClock.running = true
    }

    Component.onCompleted: refreshWorldClocks()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
        onDateChanged: root.refreshWorldClocks()
    }

    Process {
        id: utcClock
        command: ["date", "+UTC %H:%M"]
        environment: ({ TZ: "UTC" })

        stdout: StdioCollector {
            onStreamFinished: root.utcClockText = text.trim()
        }
    }

    Process {
        id: centralEuropeanClock
        command: ["date", "+%Z %H:%M"]
        environment: ({ TZ: "Europe/Berlin" })

        stdout: StdioCollector {
            onStreamFinished: root.centralEuropeanClockText = text.trim()
        }
    }

    Loader {
        active: root.isPrimary

        sourceComponent: Component {
            NotificationCenter {
                hostWindow: root
                theme: root.theme
            }
        }
    }

    Loader {
        active: root.isPrimary

        sourceComponent: Component {
            VolumeOsd {
                hostWindow: root
                theme: root.theme
                services: root.services
            }
        }
    }

    CalendarPopup {
        id: calendarPopup
        hostWindow: root
        theme: root.theme
    }

    NetworkPopup {
        id: networkPopup
        hostWindow: root
        theme: root.theme
        services: root.services
    }

    InfoPopup {
        id: infoPopup
        hostWindow: root
        theme: root.theme
    }
}
