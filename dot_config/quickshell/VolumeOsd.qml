import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    required property var hostWindow
    required property var theme
    required property var services

    readonly property int volume: Math.max(0, Math.min(100, services.audioPercent))
    readonly property bool muted: services.audioMuted
    property bool showing: false

    readonly property string icon: muted ? "" : ""

    function present() {
        showing = true
        hideTimer.restart()
    }

    IpcHandler {
        target: "volumeOsd"

        function display(): bool {
            root.present()
            return true
        }
    }

    Timer {
        id: hideTimer

        interval: 1400
        onTriggered: root.showing = false
    }

    PopupWindow {
        id: osdWindow

        readonly property int bottomMargin: 30

        anchor.window: root.hostWindow
        anchor.adjustment: PopupAdjustment.Slide
        anchor.rect.x: Math.round(root.hostWindow.width / 2 - width / 2)
        anchor.rect.y: Math.round((root.hostWindow.screen ? root.hostWindow.screen.height : 0) - height - bottomMargin)
        implicitWidth: 400
        implicitHeight: 73
        color: "transparent"
        grabFocus: false
        visible: root.showing
        mask: Region {}

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: root.theme.panel
            border.width: 1
            border.color: root.theme.highlight

            Text {
                id: volumeIcon

                anchors.left: parent.left
                anchors.leftMargin: 23
                anchors.verticalCenter: parent.verticalCenter
                width: 30
                text: root.icon
                color: root.muted ? root.theme.red : root.theme.pink
                font.family: root.theme.iconFontFamily
                font.pixelSize: 25
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                id: volumeTrack

                anchors.left: volumeIcon.right
                anchors.leftMargin: 18
                anchors.right: volumeLabel.left
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                height: 10
                radius: 5
                color: root.theme.highlight

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: root.muted ? 0 : Math.round(parent.width * root.volume / 100)
                    radius: parent.radius
                    color: root.theme.pink

                    Behavior on width {
                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            Text {
                id: volumeLabel

                anchors.right: parent.right
                anchors.rightMargin: 23
                anchors.verticalCenter: parent.verticalCenter
                width: 65
                text: root.muted ? "Muted" : root.volume + "%"
                color: root.muted ? root.theme.red : root.theme.foreground
                font.family: root.theme.fontFamily
                font.pixelSize: Math.round(root.theme.fontSizeSmall * 1.25)
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
